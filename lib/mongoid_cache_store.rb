require "mongoid_cache_store/version"

module MongoidCacheStore
end

class CacheStore

  def initialize
    @doc_ids_hash = {}
    @related_docs_hash = {}
    @documents = {}
  end

#  [{field_name: 'image_id', klass: Users::ProfileImage}]
  def cache_docs(doc_ids, doc_class, related_infos = [])
    doc_type = doc_class.to_s.underscore
    @doc_ids_hash[doc_type] ||= {}
    [doc_ids].flatten.compact.uniq.each{|doc_id| @doc_ids_hash[doc_type][doc_id.to_s] = nil}
    @related_docs_hash[doc_type] ||= []
    @related_docs_hash[doc_type] += related_infos

    self
  end

  def document(doc_id, doc_class)
    return nil if doc_id.blank?
    doc_type = doc_class.to_s.underscore
    ensure_query(doc_class, doc_id)

    @documents[doc_type][doc_id.to_s]
  end

  def valid_doc_ids(doc_class, doc_ids = nil)
    doc_type = doc_class.to_s.underscore
    ensure_query(doc_class, doc_ids)

    doc_ids.blank? ? cached_ids(doc_type) : doc_ids.select{|doc_id| @documents[doc_type][doc_id.to_s].present?}
  end

  def sorted_documents(doc_class, doc_ids = nil)
    doc_type = doc_class.to_s.underscore
    ensure_query(doc_class, doc_ids)
    return [] if @documents[doc_type].blank?

    doc_ids == nil ?
      @documents[doc_type].values.compact :
      doc_ids.map{|doc_id| @documents[doc_type][doc_id.to_s]}.compact
  end

  private

  def cached_ids(doc_type)
    return [] if @documents[doc_type].blank?
    @documents[doc_type].select{|k,v| v.present?}.keys.compact
  end

  # ensure that there are no missing docs for doc_class
  def ensure_query(doc_class, doc_ids)
    doc_ids = [doc_ids].flatten.uniq.map(&:to_s)
    doc_type = doc_class.to_s.underscore

    if doc_ids.present? && (@doc_ids_hash[doc_type].blank? || doc_ids.reject{|doc_id| @doc_ids_hash[doc_type].has_key?(doc_id.to_s)}.present?)
      cache_docs(doc_ids, doc_class)
    end

    if @documents[doc_type].blank? || @doc_ids_hash[doc_type].keys.reject{|doc_id| @documents[doc_type].has_key?(doc_id.to_s)}.present?
      find_documents(doc_type)
    end
  end

  # update cache for doc_type
  def find_documents(doc_type)
    klass = doc_type.camelize.constantize

    return if @doc_ids_hash[doc_type].blank?

    # find docs with ids missing from cache
    doc_ids = @doc_ids_hash[doc_type].keys
    doc_ids -= @documents[doc_type].keys if @documents[doc_type]

    return if doc_ids.blank?

    docs = klass.where(:_id.in => doc_ids.dup).to_a

    @related_docs_hash[doc_type].each do |related_doc|
      related_doc_ids = docs.map do |doc|
        field_name = related_doc[:field_name]
        field_names = field_name.split(".")
        field_names.each do |fname|
          if doc.respond_to?(:each)
            doc = doc.map{|r_doc| r_doc.send(fname)}.flatten
          else
            doc = doc.send(fname)
          end
        end
        doc
      end.flatten.uniq
      cache_docs(related_doc_ids, related_doc[:klass])
    end

    @documents[doc_type] ||= {}
    doc_ids.each{|doc_id| @documents[doc_type].store(doc_id, nil)}
    (docs || []).each{|doc| @documents[doc_type][doc.id.to_s] = doc}
  end

end

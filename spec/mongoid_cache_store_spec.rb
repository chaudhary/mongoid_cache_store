require "spec_helper"

RSpec.describe MongoidCacheStore do
  it "has a version number" do
    expect(MongoidCacheStore::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end

RSpec.describe Mimikyu do
  describe Mimikyu::Request do
    it "リクエストラインを正しくパースできる" do
      allow_any_instance_of(Object).to receive(:gets).and_return("GET /test.html HTTP/1.0")
      request = Mimikyu::Request.new(Object.new)
      expect(request.method).to eq("GET")
      expect(request.uri).to eq("/test.html")
      expect(request.http_version).to eq("HTTP/1.0")
    end

    it "メソッドをupper caseに変換できる" do
      allow_any_instance_of(Object).to receive(:gets).and_return("get /test.html HTTP/1.0")
      request = Mimikyu::Request.new(Object.new)
      expect(request.method).to eq("GET")
      expect(request.uri).to eq("/test.html")
      expect(request.http_version).to eq("HTTP/1.0")
    end

    it "リクエストラインが不正なときHttpErrorをraiseする" do
      allow_any_instance_of(Object).to receive(:gets).and_return("/test.html HTTP/1.0")
      expect{ Mimikyu::Request.new(Object.new) }.to raise_error(Mimikyu::HttpError)
    end
  end
end

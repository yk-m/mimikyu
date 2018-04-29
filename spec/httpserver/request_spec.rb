RSpec.describe Httpserver do
  describe Httpserver::Request do
    it "リクエストラインを正しくパースできる" do
      allow_any_instance_of(Object).to receive(:gets).and_return("GET /test.html HTTP/1.0")
      request = Httpserver::Request.new(Object.new)
      expect(request.method).to eq("GET")
      expect(request.uri).to eq("/test.html")
      expect(request.http_version).to eq("HTTP/1.0")
    end

    it "メソッドをupper caseに変換できる" do
      allow_any_instance_of(Object).to receive(:gets).and_return("get /test.html HTTP/1.0")
      request = Httpserver::Request.new(Object.new)
      expect(request.method).to eq("GET")
      expect(request.uri).to eq("/test.html")
      expect(request.http_version).to eq("HTTP/1.0")
    end

    it "リクエストラインが不正なときHttpErrorをraiseする" do
      allow_any_instance_of(Object).to receive(:gets).and_return("/test.html HTTP/1.0")
      expect{ Httpserver::Request.new(Object.new) }.to raise_error(Httpserver::HttpError)
    end
  end
end

require 'rack/etag'

describe Rack::ETag do
  def sendfile_body
    res = ['Hello World']
    def res.to_path ; "/tmp/hello.txt" ; end
    res
  end

  should "set ETag if none is set if status is 200" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.equal "\"65a8e27d8879283831b664bd8b7f0ad4\""
  end

  should "set ETag if none is set if status is 201" do
    app = lambda { |env| [201, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.equal "\"65a8e27d8879283831b664bd8b7f0ad4\""
  end

  should "not change ETag if it is already set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'ETag' => '"abc"'}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.equal "\"abc\""
  end

  should "not set ETag if Last-Modified is set" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain', 'Last-Modified' => Time.now.httpdate}, ["Hello, World!"]] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.be.nil
  end

  should "not set ETag if a sendfile_body is given" do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, sendfile_body] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.be.nil
  end

  should "not set ETag if a status is not 200 or 201" do
    app = lambda { |env| [401, {'Content-Type' => 'text/plain'}, ['Access denied.']] }
    response = Rack::ETag.new(app).call({})
    response[1]['ETag'].should.be.nil
  end
end

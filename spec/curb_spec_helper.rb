module CurbSpecHelper
  def http_request(method, uri, options = {}, &block)
    uri = Addressable::URI.heuristic_parse(uri)
    curl = Curl::Easy.new
    curl.url = uri.omit(:userinfo).to_s 
    curl.username = uri.user
    curl.password = uri.password
    curl.timeout = 10

    #curl.headers = options[:headers] if options[:headers]
    if headers = options[:headers]
      headers.each {|k,v| curl.headers[k] = v }
    end

    case method
    when :post
      fields = options[:body]
      if fields.respond_to?(:map)
        curl.post_body = fields.map{|f,k| "#{curl.escape(f)}=#{curl.escape(k)}"}.join('&')
      else
        curl.post_body = fields
      end
    when :put
      curl.put_data = options[:body]
    when :head
      curl.head = true
    when :delete
      curl.delete = true
    when :get
    else
      # XXX: nil is treated like a GET
    end

    curl.http(method)

    status, headers = Curl::Easy::WebmockHelper.parse_header_string(curl.header_str)

    OpenStruct.new(
      :body => curl.body_str,
      :headers => WebMock::Util::Headers.normalize_headers(headers),
      :status => curl.response_code.to_s,
      :message => status
    )
  end

  def default_client_request_headers(request_method = nil, has_body = false)
    nil
  end

  def client_timeout_exception_class
    Curl::Err::TimeoutError
  end

  def connection_refused_exception_class
    Curl::Err::ConnectionFailedError
  end

  def setup_expectations_for_real_request(options = {})
    #TODO
  end

  def http_library
    :curb
  end
end

require 'net/http'

module ApplicationHelper
  PROXY_SERVER = '192.11.225.125'
  PROXY_PORT   = 8000

  def fetch(url)
    url = URI.parse(url)
    req = Net::HTTP::Proxy(PROXY_SERVER, PROXY_PORT)::Get.new(url.path)
    res = Net::HTTP::Proxy(PROXY_SERVER, PROXY_PORT).start(url.host, url.port) { |http|
      http.request(req)
    }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return res
    else
      return nil
    end
  end
end

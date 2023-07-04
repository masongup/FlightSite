require 'roda'
require 'nokogiri'
require 'rest-client'
require_relative 'date_compute'

class FlightSite < Roda
  plugin :render, engine: 'haml'

  route do |r|
    r.root do
      view('site_functions', { locals: { errors: { } } } )
    end

    r.get 'SearchNodm' do
      nodm_input = request.params['nodm']

      if !nodm_input
        view('site_functions', { locals: { errors: { } } } )
      elsif /\A[A-Za-z]{3,4}\z/ === nodm_input
        params = { 
          method: 'displayByICAOs', 
          reportType: 'RAW', 
          formatType: 'DOMESTIC',
          retrieveLocId: nodm_input, 
          actionType: 'notamRetrievalByICAOs' 
          }

        begin
          url = 'https://pilotweb.nas.faa.gov/PilotWeb/notamRetrievalByICAOAction.do'
          result = RestClient::Request.execute(method: :get, url: url, timeout: 5, headers: { params: params })
          parsed = Nokogiri::HTML(result)

          norm_results = parsed.css('#resultsHomeLeft #notamRight span').map { |x| x.text.gsub('!', '') }
          
          view('do_search_nodm', { locals: { data: norm_results, nodm: nodm_input } } )
        rescue => e
          view('site_functions', { locals: { errors: { nodm_error: 'An error occured trying to retrieve the NODMs' } } } )
        end
      else
        view('site_functions', { locals: { errors: { nodm_error: 'Invalid ICAO code' } } } )
      end
    end

    r.get 'ConvertTime' do
      params = request.params
      depTimeStr = params['DepTime']
      eteStr = params['ETE']
      etaStr = DateCompute.convert_time(depTimeStr, eteStr)
      view('do_convert_time', { locals: { depTime: depTimeStr, ete: eteStr, eta: etaStr } } )
    end
  end
end

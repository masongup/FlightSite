require 'sinatra/base'
require 'nokogiri'
require 'rest-client'
require_relative 'date_compute'

class FlightSite < Sinatra::Base
  configure :production do
    enable :logging
    file = File.new('/var/flight_site_logs/log.txt', 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  get('/') do
    erb(:site_functions, { locals: { errors: { } } } )
  end

  get('/SearchNodm') do
    nodm_input = params['nodm']

    if !nodm_input
      erb(:site_functions, { locals: { errors: { } } } )
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
        
        erb(:do_search_nodm, { locals: { data: norm_results, nodm: nodm_input } } )
      rescue => e
        logger.error e.to_s
        erb(:site_functions, { locals: { errors: { nodm_error: 'An error occured trying to retrieve the NODMs' } } } )
      end
    else
      erb(:site_functions, { locals: { errors: { nodm_error: 'Invalid ICAO code' } } } )
    end
  end

  get('/ConvertTime') do
    depTimeStr = params['DepTime']
    eteStr = params['ETE']
    etaStr = DateCompute.convert_time(depTimeStr, eteStr)
    erb(:do_convert_time, { locals: { depTime: depTimeStr, ete: eteStr, eta: etaStr } } )
  end
end

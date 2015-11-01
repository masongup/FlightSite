require 'sinatra'
require 'nokogiri'
require 'rest-client'

get('/') do
  'Hello, World!'
end

get('/search_nodm') do
  nodm_input = params['nodm']

  if !nodm_input
    erb(:search_nodm, { locals: { site_error: nil } } )
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
      
      erb(:do_search_nodm, { locals: { data: norm_results } } )
    rescue => e
      logger.error e.to_s
      erb(:search_nodm, { locals: { site_error: 'An error occured trying to retrieve the NODMs' } } )
    end
  else
    erb(:search_nodm, { locals: { site_error: 'Invalid ICAO code' } } )
  end
end

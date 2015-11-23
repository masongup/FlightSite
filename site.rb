require 'sinatra'
require 'nokogiri'
require 'rest-client'
require 'time'

get('/') do
  'Hello, World!'
end

get('/Functions') do
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
      
      erb(:do_search_nodm, { locals: { data: norm_results } } )
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
  format_str = '%d/%H%M'
  eteMatch = /(\d\d)(\d\d)/.match(eteStr)
  depTime = Time.strptime(depTimeStr, format_str)
  plus_s = (eteMatch[1].to_i * 60 + eteMatch[2].to_i) * 60
  t2 = depTime + plus_s
  etaStr = t2.strftime(format_str)
  erb(:do_convert_time, { locals: { depTime: depTimeStr, ete: eteStr, eta: etaStr } } )
end

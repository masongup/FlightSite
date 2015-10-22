require 'sinatra'
require 'nokogiri'
require 'rest-client'

get('/') do
	'Hello, World!'
end

get('/search_nodm') do
	erb(:search_nodm)
end

get '/do_search_nodm' do
	nodm_input = params['nodm']
  
	params = { 
		method: 'displayByICAOs', 
		reportType: 'RAW', 
		formatType: 'DOMESTIC',
		retrieveLocId: nodm_input, 
		actionType: 'notamRetrievalByICAOs' 
		}

	url = 'https://pilotweb.nas.faa.gov/PilotWeb/notamRetrievalByICAOAction.do'
	result = RestClient.get(url, { params: params })
	parsed = Nokogiri::HTML(result)

	norm_results = parsed.css('#resultsHomeLeft #notamRight span').map { |x| x.text.gsub('!', '') }
  
	erb(:do_search_nodm, { locals: { data: norm_results } } )
end
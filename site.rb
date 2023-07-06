require 'roda'
require 'faraday'
require 'json'
require 'securerandom'
require_relative 'date_compute'

class FlightSite < Roda
  plugin :render, engine: 'haml'
  plugin :sessions, secret: SecureRandom.alphanumeric(64)
  plugin :flash

  route do |r|
    r.root do
      view('site_functions', { locals: { error: flash['error'] } } )
    end

    r.get 'SearchNodm' do
      nodm_input = request.params['nodm']

      if !nodm_input
        view('site_functions', { locals: { errors: { } } } )
      elsif /\A[A-Za-z]{3,4}\z/ === nodm_input
        params = {
          designatorsForLocation: nodm_input,
          searchType: 0,
          notamsOnly: true
        }

        begin
          url = 'https://notams.aim.faa.gov/notamSearch/search'
          result = Faraday.post(url, params)
          parsed = JSON.parse(result.body)
          norm_results = parsed.map { |nr| nr['traditionalMessageFrom4thWord'] }
          view('do_search_nodm', { locals: { data: norm_results, nodm: nodm_input } })
        rescue => e
          flash['error'] = 'An error occured trying to retrieve the NODMs'
          r.redirect '/'
        end
      else
        flash['error'] = 'Invalid ICAO code'
        r.redirect '/'
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

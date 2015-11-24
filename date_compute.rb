require 'time'

class DateCompute
  def self.convert_time(depTimeStr, eteStr)
    format_str = '%d/%H%M'
    eteMatch = /(\d\d)(\d\d)/.match(eteStr)
    depTime = Time.strptime(depTimeStr, format_str)
    plus_s = (eteMatch[1].to_i * 60 + eteMatch[2].to_i) * 60
    t2 = depTime + plus_s
    t2.strftime(format_str)
  end
end

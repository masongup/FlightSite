require_relative '../date_compute'

describe DateCompute do
  it 'does basic computation right' do
    expect(DateCompute.convert_time('01/1900', '0616')).to eq '02/0116'
  end
end

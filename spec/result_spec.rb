require 'spec_helper'

describe Enerscore::Result do

  describe 'initialization' do
    subject { Enerscore::Result.new json }
    let(:json) do 
      {
        "electricBaseloadTotalType" => {
          "energyTypeId" => 2, 
          "energyTypeCode" => "kwh", 
          "energyTypeDescription" => "Kilowat Hours"
        },
        status: 'success'
      }
    end

    it 'recursively maps the input hash to methods' do
      result = subject
      expect(result.status).to eq 'success'

      expect(result.electricBaseloadTotalType.energyTypeId).to eq 2
      expect(result.electricBaseloadTotalType.energyTypeCode).to eq "kwh"
      expect(result.electricBaseloadTotalType.energyTypeDescription).to eq "Kilowat Hours"
    end
  end
end

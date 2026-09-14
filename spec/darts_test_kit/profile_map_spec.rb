require 'darts_test_kit'

RSpec.describe DartsTestKit::ProfileMap do
  describe '.profiles_for' do
    it 'maps Patient to the US Core Patient profile' do
      expect(described_class.profiles_for('Patient', :us_core))
        .to eq(['http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'])
    end

    it 'maps ServiceRequest to the US Core ServiceRequest profile' do
      expect(described_class.profiles_for('ServiceRequest', :us_core))
        .to eq(['http://hl7.org/fhir/us/core/StructureDefinition/us-core-servicerequest'])
    end

    it 'omits ambiguous US Core types (e.g. Observation) so validation falls back to meta.profile' do
      expect(described_class.profiles_for('Observation', :us_core)).to eq([])
    end

    it 'returns an empty array for unknown resource types or targets' do
      expect(described_class.profiles_for('Foo', :us_core)).to eq([])
      expect(described_class.profiles_for('Patient', :unknown_target)).to eq([])
    end
  end

  describe '.base_for' do
    it 'returns the US Core base' do
      expect(described_class.base_for(:us_core)).to eq('http://hl7.org/fhir/us/core/StructureDefinition')
    end
  end
end

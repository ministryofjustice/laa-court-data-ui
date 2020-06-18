# frozen_string_literal: true

FactoryBot.factories.map(&:name).each do |factory_name|
  context "The #{factory_name} factory" do
    describe '#build' do
      it 'builds valid user' do
        expect(build(factory_name)).to be_valid
      end
    end
  end
end

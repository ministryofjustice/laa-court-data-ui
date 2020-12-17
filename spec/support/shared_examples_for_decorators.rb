# frozen_string_literal: true

RSpec.shared_examples 'a base decorator' do
  it { is_expected.to respond_to(:object) }

  describe '#object' do
    subject { decorator.object }

    it { is_expected.to be(object) }
  end

  it { expect(decorator).to delegate_method(:translate).to(:context) }
  it { expect(decorator).to delegate_method(:t).to(:context) }
  it { expect(decorator).to delegate_method(:tag).to(:context) }
  it { expect(decorator).to delegate_method(:decorate_all).to(:context) }

  describe '#translate' do
    subject(:call) { decorator.translate('my.translation') }

    context 'when translation exists' do
      around do |example|
        original_backend = I18n.backend
        mock_backend = I18n::Backend::Simple.new
        mock_backend.load_translations(Rails.root.join('spec', 'fixtures', 'i18n', 'mock.yml'))

        I18n.backend = mock_backend
        example.run
        I18n.backend = original_backend
      end

      it { is_expected.to eql 'my mock translation' }
    end

    # NOTE: error raising optional, see config/environments/test.rb
    # config.action_view.raise_on_missing_translations = true
    context 'when translation does not exist' do
      it { expect { call }.to raise_error(I18n::MissingTranslationData) }
    end
  end

  describe '#context' do
    subject { decorator.context }

    it 'aliased to #view' do
      expect(decorator.method(:view)).to eql(decorator.method(:context))
    end

    it 'aliased to #h' do
      expect(decorator.method(:h)).to eql(decorator.method(:context))
    end
  end
end

# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  describe '#order_by (private)' do
    let(:users_relation)       { instance_double('ActiveRecord::Relation') }
    let(:ordered_relation)     { instance_double('ActiveRecord::Relation') }
    let(:pagy_obj)             { instance_double('Pagy') }

    before do
      # Seed the controller's @users with a relation-like double
      controller.instance_variable_set(:@users, users_relation)

      # Stub pagy to return [pagy_obj, ordered_relation] when called with ordered_relation
      allow(controller).to receive(:pagy).with(ordered_relation).and_return([pagy_obj, ordered_relation])
    end

    context "when column is 'name' and order is 'asc'" do
      it 'orders by first_name ASC, last_name ASC and updates @users' do
        allow(users_relation).to have_received(:order)
          .with(first_name: :asc, last_name: :asc)
          .and_return(ordered_relation)

        controller.send(:order_by, 'name', 'asc')

        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
        expect(controller.instance_variable_get(:@pagy)).to eq(pagy_obj)
      end
    end

    context "when column is 'name' and order is 'desc'" do
      it 'orders by first_name DESC, last_name DESC and updates @users' do
        allow(users_relation).to have_received(:order)
          .with(first_name: :desc, last_name: :desc)
          .and_return(ordered_relation)

        controller.send(:order_by, 'name', 'desc')

        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
        expect(controller.instance_variable_get(:@pagy)).to eq(pagy_obj)
      end
    end

    context "when column is any other column and order is 'asc'" do
      it 'orders by ASC"' do
        column = 'email'
        allow(users_relation).to have_received(:order)
          .with("#{column} ASC")
          .and_return(ordered_relation)

        controller.send(:order_by, column, 'asc')

        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
        expect(controller.instance_variable_get(:@pagy)).to eq(pagy_obj)
      end
    end

    context "when column is any other column and order is not 'asc' (e.g., desc)" do
      it 'orders by DESC"' do
        column = 'last_sign_in_at'
        allow(users_relation).to have_received(:order)
          .with("#{column} DESC")
          .and_return(ordered_relation)

        controller.send(:order_by, column, 'desc')

        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
        expect(controller.instance_variable_get(:@pagy)).to eq(pagy_obj)
      end
    end
  end
end

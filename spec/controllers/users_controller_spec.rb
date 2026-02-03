# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  describe '#order_by (private)' do
    let(:users_relation)       { instance_double('ActiveRecord::Relation') }
    let(:ordered_relation)     { instance_double('ActiveRecord::Relation') }
    let(:pagy_obj)             { instance_double('Pagy') }

    before do
      controller.instance_variable_set(:@users, users_relation)

      # Stub pagy
      allow(controller).to receive(:pagy).and_return([pagy_obj, ordered_relation])

      # Stub order on relation
      allow(users_relation).to receive(:order).and_return(ordered_relation)
    end

    context "when column is 'name' and order is 'asc'" do
      it 'orders by first_name ASC, last_name ASC' do
        controller.send(:order_by, 'name', 'asc')

        expect(users_relation)
          .to have_received(:order)
          .with(first_name: :asc, last_name: :asc)

        expect(controller).to have_received(:pagy).with(ordered_relation)
        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
      end
    end

    context "when column is 'name' and order is 'desc'" do
      it 'orders by first_name DESC, last_name DESC' do
        controller.send(:order_by, 'name', 'desc')

        expect(users_relation)
          .to have_received(:order)
          .with(first_name: :desc, last_name: :desc)

        expect(controller).to have_received(:pagy).with(ordered_relation)
        expect(controller.instance_variable_get(:@users)).to eq(ordered_relation)
      end
    end

    context "when a non-name column is given and order is 'asc'" do
      it 'orders by column ASC' do
        controller.send(:order_by, 'email', 'asc')

        expect(users_relation)
          .to have_received(:order)
          .with("email ASC")

        expect(controller).to have_received(:pagy).with(ordered_relation)
      end
    end

    context "when a non-name column is given and order is not asc" do
      it 'orders by column DESC' do
        controller.send(:order_by, 'last_sign_in_at', 'desc')

        expect(users_relation)
          .to have_received(:order)
          .with("last_sign_in_at DESC")

        expect(controller).to have_received(:pagy).with(ordered_relation)
      end
    end
  end
end

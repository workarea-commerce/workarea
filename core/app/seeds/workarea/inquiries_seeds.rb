module Workarea
  class InquiriesSeeds
    def perform
      puts 'Adding inquiries...'

      Inquiry.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        order_id: Order.first.id,
        subject: Workarea.config.inquiry_subjects.first.first,
        message: Faker::Lorem.paragraph
      )
    end
  end
end

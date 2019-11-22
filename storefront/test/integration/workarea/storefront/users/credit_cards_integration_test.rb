require 'test_helper'

module Workarea
  module Storefront
    module Users
      class CreditCardsIntegrationTest < Workarea::IntegrationTest
        setup :set_user
        setup :set_post_login

        def set_user
          @user = create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        end

        def set_post_login
          post storefront.login_path,
            params: { email: 'bcrouse@workarea.com', password: 'W3bl1nc!' }
        end

        def test_adds_credit_cards
          post storefront.users_credit_cards_path,
            params: {
              credit_card: {
                number: '1',
                first_name: 'Ben',
                last_name: 'Crouse',
                month: '1',
                year: (Time.current.year + 1).to_s,
                cvv: '999'
              }
            }

          assert_redirected_to(storefront.users_account_path)

          payment_profile = Payment::Profile.lookup(PaymentReference.new(@user))

          credit_card = payment_profile.credit_cards.first
          assert_equal('Ben', credit_card.first_name)
          assert_equal('Crouse', credit_card.last_name)
          assert_equal(1, credit_card.month)
          assert_equal(Time.current.year + 1, credit_card.year)
          assert(credit_card.token.present?)
        end

        def test_can_update_a_credit_card
          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          credit_card = create_saved_credit_card(profile: profile)

          patch storefront.users_credit_card_path(credit_card),
            params: {
              credit_card: {
                month: '2',
                year: next_year.to_s,
                cvv: '999'
              }
            }

          credit_card.reload
          assert_equal(2, credit_card.month)
          assert_equal(next_year, credit_card.year)
        end

        def test_removes_credit_cards
          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          credit_card = create_saved_credit_card(profile: profile)

          delete storefront.users_credit_card_path(credit_card)
          payment_profile = Payment::Profile.lookup(PaymentReference.new(@user))
          assert(payment_profile.credit_cards.empty?)
        end


        def test_requires_login
          delete storefront.logout_path

          get storefront.new_users_credit_card_path
          assert_redirected_to(storefront.login_path)

          post storefront.users_credit_cards_path
          assert_redirected_to(storefront.login_path)

          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          credit_card = create_saved_credit_card(profile: profile)

          get storefront.edit_users_credit_card_path(credit_card)
          assert_redirected_to(storefront.login_path)

          patch storefront.users_credit_card_path(credit_card)
          assert_redirected_to(storefront.login_path)

          delete storefront.users_credit_card_path(credit_card)
          assert_redirected_to(storefront.login_path)
        end
      end
    end
  end
end

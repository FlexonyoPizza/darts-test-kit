module DartsTestKit
  # Optional: obtains an access token from a Trust Service Provider secured with OAuth2 client
  # credentials via a signed JWT bearer assertion (SMART Backend Services). Run this group once per
  # session before the operation groups; the resulting token is stored for the session and sent
  # automatically on every operation call (see OperationClient#access_token).
  #
  # This group is the only place authorization is configured. Skip it entirely for a Trust Service
  # Provider that does not require authorization, and the operations are called with no
  # Authorization header at all.
  class ValidatorObtainAccessToken < Inferno::Test
    id :darts_validator_obtain_access_token
    title 'Obtain an access token (SMART Backend Services)'
    description %(
      Exchanges client credentials for an access token using the OAuth2 client credentials grant with
      a signed JWT bearer assertion, as described by
      [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/backend-services.html). Provide
      the Trust Service Provider's token endpoint, a client ID, and a signing key. The resulting
      access token is stored for the session and sent automatically on the operation calls that
      follow, so no token has to be entered anywhere else.

      Leave the credentials blank to skip this step entirely.
    )

    input :tsp_auth,
          title: 'Trust Service Provider Authorization',
          type: :auth_info,
          optional: true,
          options: {
            mode: 'auth',
            components: [
              { name: :auth_type, default: 'backend_services', locked: true }
            ]
          }

    output :bearer_token

    run do
      omit_if tsp_auth.blank? || tsp_auth.client_id.blank? || tsp_auth.token_url.blank?,
              'No Backend Services credentials were provided. The operations will be invoked without ' \
              'an Authorization header.'

      post(tsp_auth.token_url, body: tsp_auth.oauth2_refresh_params, headers: tsp_auth.oauth2_refresh_headers)
      assert_response_status([200, 201])
      assert_valid_json(request.response_body)

      tsp_auth.update_from_response_body(request)
      assert tsp_auth.access_token.present?, 'The token response did not include an access_token.'

      output bearer_token: tsp_auth.access_token, tsp_auth: tsp_auth
    end
  end

  class ValidatorObtainAccessTokenGroup < Inferno::TestGroup
    id :darts_validator_obtain_access_token_group
    title 'Obtain Access Token (SMART Backend Services)'
    description %(
      Optional, and the only place authorization is configured. If the Trust Service Provider requires
      OAuth2 client credentials authorization, run this group first: the token it obtains is sent
      automatically on the operation calls that follow.

      Skip this group for a Trust Service Provider that does not require authorization - the
      operations are then called with no Authorization header, and the base URL is the only input
      they need.
    )
    run_as_group

    test from: :darts_validator_obtain_access_token
  end
end

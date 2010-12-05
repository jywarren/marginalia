# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_marginalia_session',
  :secret      => 'd7ccf3c19f5484facd775931690cbe4d383525abbdd3c0b58c4923b2f1c1e6827829dae66bbc37d93bcc76ca3b32614e9f0fc489e3eb1be4f486ce77a9b5d995'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

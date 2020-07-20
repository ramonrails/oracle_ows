# frozen_string_literal: true

# If any of the configuration keys above are not set, your application will
# raise an error during initialization. This method is preferred because it
# prevents runtime errors in a production application due to improper
# configuration.
Dotenv.require_keys('URL', 'USERNAME', 'PASSWORD')

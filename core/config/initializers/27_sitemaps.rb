# Quiet the output of the generator in tests to eliminate
# the noise when running the test suite.
SitemapGenerator.verbose = !Rails.env.test?

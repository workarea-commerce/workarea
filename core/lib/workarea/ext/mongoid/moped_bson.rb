# NOTE
# This exists to fix issues with deserializing sessions
# containing Moped::BSON ids. It can be removed in v0.5.
module Moped
  BSON = ::BSON
end

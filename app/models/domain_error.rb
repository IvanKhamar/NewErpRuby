# A broken business rule. The message is for people (Ukrainian, like the other versions) and has no internals;
# the API answers 400 "Порушено бізнес-правило" with it.
class DomainError < StandardError; end

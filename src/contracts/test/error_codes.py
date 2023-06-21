





error_ENTRYPOINT_SHOULD_NOT_RECEIVE_TEZ                                                                 = 0
error_INCORRECT_TEZ_FEE                                                                                 = 1

error_LAMBDA_NOT_FOUND                                                                                  = 2
error_UNABLE_TO_UNPACK_LAMBDA                                                                           = 3
error_UNABLE_TO_UNPACK_ACTION_PARAMETER                                                                 = 4

error_CALCULATION_ERROR                                                                                 = 5
error_CONFIG_VALUE_ERROR                                                                                = 6
error_CONFIG_VALUE_TOO_HIGH                                                                             = 7
error_CONFIG_VALUE_TOO_LOW                                                                              = 8
error_INDEX_OUT_OF_BOUNDS                                                                               = 9
error_INVALID_BLOCKS_PER_MINUTE                                                                         = 10
error_WRONG_INPUT_PROVIDED                                                                              = 11
error_WRONG_TOKEN_TYPE_PROVIDED                                                                         = 12
error_TOKEN_NOT_WHITELISTED                                                                             = 13

error_ONLY_SUPER_ADMINISTRATOR_ALLOWED                                                                  = 14
error_ONLY_ADMINISTRATOR_ALLOWED                                                                        = 15
error_ONLY_SELF_ALLOWED                                                                                 = 16
error_ONLY_WHITELISTED_ADDRESSES_ALLOWED                                                                = 17

error_SPECIFIED_ENTRYPOINT_NOT_FOUND                                                                    = 18
error_SET_ADMIN_ENTRYPOINT_NOT_FOUND                                                                    = 19
error_SET_LAMBDA_ENTRYPOINT_NOT_FOUND                                                                   = 20
error_SET_PRODUCT_LAMBDA_ENTRYPOINT_NOT_FOUND                                                           = 21
error_PAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                    = 22
error_UNPAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                  = 23
error_UPDATE_METADATA_ENTRYPOINT_NOT_FOUND                                                              = 24
error_UPDATE_BLOCKS_PER_MIN_ENTRYPOINT_NOT_FOUND                                                        = 25
error_TRANSFER_ENTRYPOINT_IN_FA12_CONTRACT_NOT_FOUND                                                    = 26
error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                     = 27



error_GET_GENERAL_CONTRACT_OPT_VIEW_IN_GOVERNANCE_CONTRACT_NOT_FOUND                                    = 28
error_ONLY_ADMINISTRATOR_OR_GOVERNANCE_ALLOWED                                                          = 29
error_ONLY_SELF_OR_SPECIFIED_ADDRESS_ALLOWED                                                            = 30









error_ADMINISTRATOR_NOT_FOUND                                                                           = 31
error_NOT_ADMIN                                                                                         = 32

error_TOKEN_EXISTS                                                                                      = 33
error_TOKEN_CONTEXT_NOT_FOUND                                                                           = 34
error_TOKEN_UNDEFINED                                                                                   = 35
error_TOKEN_PAUSED                                                                                      = 36

error_USER_NOT_FOUND                                                                                    = 37
error_CANNOT_TRANSFER                                                                                   = 38
error_INSUFFICIENT_BALANCE                                                                              = 39

error_SNAPSHOT_ALREADY_SCHEDULED                                                                        = 40
error_SNAPSHOT_IN_PAST                                                                                  = 41

error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 42
error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                         = 43









error_ADD_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                             = 44
error_REMOVE_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                          = 45
error_FA2_TOKEN_RECORD_NOT_FOUND_TO_BE_REMOVED                                                           = 46
error_TOKEN_RECORD_NOT_FOUND                                                                             = 47

error_NO_NEW_SUPER_ADMIN_FOUND                                                                           = 48
error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                      = 49









error_LAUNCH_RECORD_NOT_FOUND                                                                            = 50
error_SALE_OPTION_NOT_FOUND                                                                              = 51
error_MAX_AMOUNT_PER_WALLET_FOR_SALE_OPTION_TOTAL_EXCEEDED                                               = 52
error_MAX_AMOUNT_CAP_FOR_SALE_OPTION_EXCEEDED                                                            = 53

error_INVALID_TOKEN_ISSUANCE_TYPE                                                                        = 54
error_INVALID_TOKEN_DISTRIBUTION_TYPE                                                                    = 55
error_LAUNCH_IS_NOT_ACTIVE                                                                               = 56
error_LAUNCH_IS_NOT_PAUSED                                                                               = 57
error_LAUNCH_HAS_ENDED                                                                                   = 58
error_SALE_HAS_NOT_STARTED                                                                               = 59
error_USER_WHITELIST_RECORD_NOT_FOUND                                                                    = 60
error_USER_WHITELIST_ALLOWED_AMOUNT_EXCEEDED                                                             = 61
error_WHITELIST_OPTION_DOES_NOT_EXIST                                                                    = 62


error_SALE_END_SHOULD_BE_AFTER_SALE_START                                                                = 63
error_WHITELIST_SALE_END_SHOULD_BE_AFTER_WHITELIST_SALE_START                                            = 64
error_WHITELIST_SALE_START_NOT_SPECIFIED                                                                 = 65








error_SENDER_IS_NOT_CREATOR                                                                              = 66
error_LISTER_CANNOT_PURCHASE_HIS_LISTING                                                                 = 67
error_LISTING_HAS_EXPIRED                                                                                = 68
error_OFFER_HAS_EXPIRED                                                                                  = 69

error_CURRENCY_RECORD_NOT_FOUND                                                                          = 70
error_LISTING_RECORD_NOT_FOUND                                                                           = 71
error_OFFER_RECORD_NOT_FOUND                                                                             = 72
error_INVALID_CURRENCY                                                                                   = 73

error_SET_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 74
error_REMOVE_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                          = 75
error_CREATE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 76
error_EDIT_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 77
error_REMOVE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 78
error_PURCHASE_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                 = 79
error_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                    = 80
error_ACCEPT_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 81
error_REMOVE_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 82


error_PURCHASE_AMOUNT_CANNOT_BE_GREATER_THAN_LISTING_AMOUNT                                              = 83
error_OFFER_AMOUNT_CANNOT_BE_GREATER_THAN_LISTING_AMOUNT                                                 = 84
error_OFFER_STATUS_IS_NOT_OPEN                                                                           = 85
error_LISTING_STATUS_IS_NOT_ACTIVE                                                                       = 86
error_QUICK_BUY_OPTION_DOES_NOT_EXIST_ON_LISTING                                                         = 87








error_TREASURY_NOT_FOUND                                                                                 = 88

error_DOORMAN_CONTRACT_NOT_FOUND                                                                         = 89
error_MVK_TOKEN_CONTRACT_NOT_FOUND                                                                       = 90
error_UPDATE_OPERATORS_ENTRYPOINT_IN_MVK_TOKEN_CONTRACT_NOT_FOUND                                        = 91
error_STAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND                                                     = 92
error_UNSTAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND                                                   = 93

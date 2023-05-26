// ------------------------------------------------------------------------------
//
// General Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ENTRYPOINT_SHOULD_NOT_RECEIVE_TEZ                                                                 = 0n;
[@inline] const error_INCORRECT_TEZ_FEE                                                                                 = 1n;

[@inline] const error_LAMBDA_NOT_FOUND                                                                                  = 2n;
[@inline] const error_UNABLE_TO_UNPACK_LAMBDA                                                                           = 3n;
[@inline] const error_UNABLE_TO_UNPACK_ACTION_PARAMETER                                                                 = 4n;

[@inline] const error_CALCULATION_ERROR                                                                                 = 5n;
[@inline] const error_CONFIG_VALUE_ERROR                                                                                = 6n;
[@inline] const error_CONFIG_VALUE_TOO_HIGH                                                                             = 7n;
[@inline] const error_CONFIG_VALUE_TOO_LOW                                                                              = 8n;
[@inline] const error_INDEX_OUT_OF_BOUNDS                                                                               = 9n;
[@inline] const error_INVALID_BLOCKS_PER_MINUTE                                                                         = 10n;
[@inline] const error_WRONG_INPUT_PROVIDED                                                                              = 11n;
[@inline] const error_WRONG_TOKEN_TYPE_PROVIDED                                                                         = 12n;
[@inline] const error_TOKEN_NOT_WHITELISTED                                                                             = 13n;

[@inline] const error_ONLY_ADMINISTRATOR_ALLOWED                                                                        = 14n;
[@inline] const error_ONLY_SELF_ALLOWED                                                                                 = 15n;

[@inline] const error_SPECIFIED_ENTRYPOINT_NOT_FOUND                                                                    = 16n;
[@inline] const error_SET_ADMIN_ENTRYPOINT_NOT_FOUND                                                                    = 17n;
[@inline] const error_SET_LAMBDA_ENTRYPOINT_NOT_FOUND                                                                   = 18n;
[@inline] const error_SET_PRODUCT_LAMBDA_ENTRYPOINT_NOT_FOUND                                                           = 19n;
[@inline] const error_PAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                    = 20n;
[@inline] const error_UNPAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                  = 21n;
[@inline] const error_UPDATE_METADATA_ENTRYPOINT_NOT_FOUND                                                              = 22n;
[@inline] const error_UPDATE_BLOCKS_PER_MIN_ENTRYPOINT_NOT_FOUND                                                        = 23n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA12_CONTRACT_NOT_FOUND                                                    = 24n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                     = 25n;

// ------------------------------------------------------------------------------
//
// Security Token Error
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                                                                           = 0n;
[@inline] const error_NOT_ADMIN                                                                                         = 1n;

[@inline] const error_TOKEN_EXISTS                                                                                      = 2n;
[@inline] const error_tokenContext_NOT_FOUND                                                                            = 3n;
[@inline] const error_TOKEN_UNDEFINED                                                                                   = 4n;
[@inline] const error_TOKEN_PAUSED                                                                                      = 5n;

[@inline] const error_USER_NOT_FOUND                                                                                    = 6n;
[@inline] const error_CANNOT_TRANSFER                                                                                   = 6n;
[@inline] const error_INSUFFICIENT_BALANCE                                                                              = 7n;

[@inline] const error_SNAPSHOT_ALREADY_SCHEDULED                                                                        = 8n;
[@inline] const error_SNAPSHOT_IN_PAST                                                                                  = 9n;

[@inline] const error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 10n;




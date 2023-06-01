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

[@inline] const error_ONLY_SUPER_ADMINISTRATOR_ALLOWED                                                                  = 14n;
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


// missing shared helpers errors
[@inline] const error_GET_GENERAL_CONTRACT_OPT_VIEW_IN_GOVERNANCE_CONTRACT_NOT_FOUND                                    = 25n;
[@inline] const error_ONLY_ADMINISTRATOR_OR_GOVERNANCE_ALLOWED                                                          = 25n;
[@inline] const error_ONLY_SELF_OR_SPECIFIED_ADDRESS_ALLOWED                                                            = 25n;



// ------------------------------------------------------------------------------
//
// Security Token Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                                                                           = 0n;
[@inline] const error_NOT_ADMIN                                                                                         = 1n;

[@inline] const error_TOKEN_EXISTS                                                                                      = 2n;
[@inline] const error_TOKEN_CONTEXT_NOT_FOUND                                                                            = 3n;
[@inline] const error_TOKEN_UNDEFINED                                                                                   = 4n;
[@inline] const error_TOKEN_PAUSED                                                                                      = 5n;

[@inline] const error_USER_NOT_FOUND                                                                                    = 6n;
[@inline] const error_CANNOT_TRANSFER                                                                                   = 6n;
[@inline] const error_INSUFFICIENT_BALANCE                                                                              = 7n;

[@inline] const error_SNAPSHOT_ALREADY_SCHEDULED                                                                        = 8n;
[@inline] const error_SNAPSHOT_IN_PAST                                                                                  = 9n;

[@inline] const error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 10n;


// ------------------------------------------------------------------------------
//
// Token Registry Errors
//
// ------------------------------------------------------------------------------


[@inline] const error_ADD_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                             = 2n;
[@inline] const error_REMOVE_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                          = 2n;
[@inline] const error_FA2_TOKEN_RECORD_NOT_FOUND_TO_BE_REMOVED                                                           = 2n;
[@inline] const error_TOKEN_RECORD_NOT_FOUND                                                                             = 2n;

[@inline] const error_NO_NEW_SUPER_ADMIN_FOUND                                                                           = 2n;
[@inline] const error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                      = 2n;


// ------------------------------------------------------------------------------
//
// Marketplace Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_SENDER_IS_NOT_CREATOR                                                                              = 2n;
[@inline] const error_LISTER_CANNOT_PURCHASE_HIS_LISTING                                                                 = 2n;
[@inline] const error_LISTING_HAS_EXPIRED                                                                                = 2n;
[@inline] const error_OFFER_HAS_EXPIRED                                                                                  = 2n;

[@inline] const error_CURRENCY_RECORD_NOT_FOUND                                                                          = 2n;
[@inline] const error_LISTING_RECORD_NOT_FOUND                                                                           = 2n;
[@inline] const error_OFFER_RECORD_NOT_FOUND                                                                             = 2n;
[@inline] const error_INVALID_CURRENCY                                                                                   = 2n;

[@inline] const error_SET_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 2n;
[@inline] const error_REMOVE_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                          = 2n;
[@inline] const error_CREATE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 2n;
[@inline] const error_REMOVE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 2n;
[@inline] const error_PURCHASE_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                 = 2n;
[@inline] const error_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                    = 2n;
[@inline] const error_ACCEPT_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 2n;
[@inline] const error_REMOVE_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 2n;




// ------------------------------------------------------------------------------
//
// Treasury Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_TREASURY_NOT_FOUND                                                                                 = 2n;

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
[@inline] const error_ONLY_ADMINISTRATOR_ALLOWED                                                                        = 15n;
[@inline] const error_ONLY_SELF_ALLOWED                                                                                 = 16n;
[@inline] const error_ONLY_WHITELISTED_ADDRESSES_ALLOWED                                                                = 17n;

[@inline] const error_SPECIFIED_ENTRYPOINT_NOT_FOUND                                                                    = 18n;
[@inline] const error_SET_ADMIN_ENTRYPOINT_NOT_FOUND                                                                    = 19n;
[@inline] const error_SET_LAMBDA_ENTRYPOINT_NOT_FOUND                                                                   = 20n;
[@inline] const error_SET_PRODUCT_LAMBDA_ENTRYPOINT_NOT_FOUND                                                           = 21n;
[@inline] const error_PAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                    = 22n;
[@inline] const error_UNPAUSE_ALL_ENTRYPOINT_NOT_FOUND                                                                  = 23n;
[@inline] const error_UPDATE_METADATA_ENTRYPOINT_NOT_FOUND                                                              = 24n;
[@inline] const error_UPDATE_BLOCKS_PER_MIN_ENTRYPOINT_NOT_FOUND                                                        = 25n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA12_CONTRACT_NOT_FOUND                                                    = 26n;
[@inline] const error_TRANSFER_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                     = 27n;


// missing shared helpers errors
[@inline] const error_GET_GENERAL_CONTRACT_OPT_VIEW_IN_GOVERNANCE_CONTRACT_NOT_FOUND                                    = 28n;
[@inline] const error_ONLY_ADMINISTRATOR_OR_GOVERNANCE_ALLOWED                                                          = 29n;
[@inline] const error_ONLY_SELF_OR_SPECIFIED_ADDRESS_ALLOWED                                                            = 30n;



// ------------------------------------------------------------------------------
//
// Security Token Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                                                                           = 31n;
[@inline] const error_NOT_ADMIN                                                                                         = 32n;

[@inline] const error_TOKEN_EXISTS                                                                                      = 33n;
[@inline] const error_TOKEN_CONTEXT_NOT_FOUND                                                                           = 34n;
[@inline] const error_TOKEN_UNDEFINED                                                                                   = 35n;
[@inline] const error_TOKEN_PAUSED                                                                                      = 36n;

[@inline] const error_USER_NOT_FOUND                                                                                    = 37n;
[@inline] const error_CANNOT_TRANSFER                                                                                   = 38n;
[@inline] const error_INSUFFICIENT_BALANCE                                                                              = 39n;

[@inline] const error_SNAPSHOT_ALREADY_SCHEDULED                                                                        = 40n;
[@inline] const error_SNAPSHOT_IN_PAST                                                                                  = 41n;

[@inline] const error_VIEW_IS_TRANSFER_VALID_NOT_FOUND                                                                  = 42n;
[@inline] const error_MINT_ENTRYPOINT_IN_FA2_CONTRACT_NOT_FOUND                                                         = 43n;


// ------------------------------------------------------------------------------
//
// Token Registry Errors
//
// ------------------------------------------------------------------------------


[@inline] const error_ADD_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                             = 44n;
[@inline] const error_REMOVE_TOKEN_ENTRYPOINT_IN_TOKEN_REGISTRY_CONTRACT_PAUSED                                          = 45n;
[@inline] const error_FA2_TOKEN_RECORD_NOT_FOUND_TO_BE_REMOVED                                                           = 46n;
[@inline] const error_TOKEN_RECORD_NOT_FOUND                                                                             = 47n;

[@inline] const error_NO_NEW_SUPER_ADMIN_FOUND                                                                           = 48n;
[@inline] const error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                      = 49n;


// ------------------------------------------------------------------------------
//
// Launchpad Errors
//
// ------------------------------------------------------------------------------


[@inline] const error_LAUNCH_RECORD_NOT_FOUND                                                                            = 50n;
[@inline] const error_SALE_OPTION_NOT_FOUND                                                                              = 51n;
[@inline] const error_MAX_AMOUNT_PER_WALLET_FOR_SALE_OPTION_TOTAL_EXCEEDED                                               = 52n;
[@inline] const error_MAX_AMOUNT_CAP_FOR_SALE_OPTION_EXCEEDED                                                            = 53n;





// ------------------------------------------------------------------------------
//
// Marketplace Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_SENDER_IS_NOT_CREATOR                                                                              = 54n;
[@inline] const error_LISTER_CANNOT_PURCHASE_HIS_LISTING                                                                 = 55n;
[@inline] const error_LISTING_HAS_EXPIRED                                                                                = 56n;
[@inline] const error_OFFER_HAS_EXPIRED                                                                                  = 57n;

[@inline] const error_CURRENCY_RECORD_NOT_FOUND                                                                          = 58n;
[@inline] const error_LISTING_RECORD_NOT_FOUND                                                                           = 59n;
[@inline] const error_OFFER_RECORD_NOT_FOUND                                                                             = 60n;
[@inline] const error_INVALID_CURRENCY                                                                                   = 61n;

[@inline] const error_SET_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 62n;
[@inline] const error_REMOVE_CURRENCY_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                          = 63n;
[@inline] const error_CREATE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 64n;
[@inline] const error_REMOVE_LISTING_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                           = 65n;
[@inline] const error_PURCHASE_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                 = 66n;
[@inline] const error_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                                    = 67n;
[@inline] const error_ACCEPT_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 68n;
[@inline] const error_REMOVE_OFFER_ENTRYPOINT_IN_MARKETPLACE_CONTRACT_PAUSED                                             = 69n;




// ------------------------------------------------------------------------------
//
// Treasury Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_TREASURY_NOT_FOUND                                                                                 = 70n;

[@inline] const error_DOORMAN_CONTRACT_NOT_FOUND                                                                         = 71n;
[@inline] const error_MVK_TOKEN_CONTRACT_NOT_FOUND                                                                       = 72n;
[@inline] const error_UPDATE_OPERATORS_ENTRYPOINT_IN_MVK_TOKEN_CONTRACT_NOT_FOUND                                        = 73n;
[@inline] const error_STAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND                                                     = 74n;
[@inline] const error_UNSTAKE_ENTRYPOINT_IN_DOORMAN_CONTRACT_NOT_FOUND                                                   = 75n;

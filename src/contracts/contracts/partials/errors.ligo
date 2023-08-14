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
// Bounty Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                                                                           = 31n;
[@inline] const error_NOT_ADMIN                                                                                         = 32n;

[@inline] const error_ONLY_ADMINISTRATOR_OR_BOUNTY_CREATOR_ALLOWED                                                      = 32n;
[@inline] const error_ONLY_ADMIN_OR_CREATOR_OR_WHITELISTED_ALLOWED                                                      = 32n;

[@inline] const error_INVALID_STATUS                                                                                    = 32n;
[@inline] const error_INVALID_STATUS_FOR_BOUNTY_REVIEW                                                                  = 32n;

[@inline] const error_MILESTONE_REWARDS_AND_TOTAL_REWARDS_DO_NOT_TALLY                                                  = 32n;
[@inline] const error_BOUNTY_RECORD_NOT_FOUND                                                                           = 32n;
[@inline] const error_APPLICANT_RECORD_NOT_FOUND                                                                        = 32n;
[@inline] const error_USER_RECORD_NOT_FOUND                                                                             = 32n;
[@inline] const error_MILESTONE_RECORD_FOR_BOUNTY_NOT_FOUND                                                             = 32n;
[@inline] const error_MILESTONE_RECORD_FOR_APPLICANT_NOT_FOUND                                                          = 32n;

[@inline] const error_BOUNTY_IS_NOT_ACTIVE                                                                              = 32n;
[@inline] const error_BOUNTY_IS_PAUSED                                                                                  = 32n;
[@inline] const error_BOUNTY_HAS_NO_SPACE_FOR_NEW_APPLICANTS                                                            = 32n;
[@inline] const error_USER_HAS_NO_SPACE_FOR_NEW_BOUNTIES                                                                = 32n;
[@inline] const error_USER_CANNOT_APPLY_FOR_NEW_BOUNTIES                                                                = 32n;
[@inline] const error_APPLICATION_STATUS_IS_NOT_PENDING                                                                 = 32n;
[@inline] const error_BOUNTY_CANNOT_BE_STOPPED_BY_USER                                                                  = 32n;
[@inline] const error_BOUNTY_HAS_ALREADY_BEEN_COMPLETED_AND_APPROVED                                                    = 32n;
[@inline] const error_MILESTONE_NEEDS_TO_BE_SPECIFIED_FOR_REVIEW                                                        = 32n;
[@inline] const error_MILESTONE_LOG_NOT_FOUND_IN_APPLICANT_RECORD                                                       = 32n;
[@inline] const error_CURRENT_MILESTONE_NOT_FOUND                                                                       = 32n;
[@inline] const error_MILESTONE_TO_REVIEW_NEEDS_TO_BE_THE_SAME_AS_CURRENT_MILESTONE                                     = 32n;
[@inline] const error_BOUNTY_HAS_REACHED_MAX_APPROVED_APPLICANTS                                                        = 32n;
[@inline] const error_BOUNTY_HAS_NO_MILESTONES                                                                          = 32n;
[@inline] const error_MILESTONE_NEEDS_TO_BE_SPECIFIED_TO_SEND_BOUNTY_REWARD                                             = 32n;

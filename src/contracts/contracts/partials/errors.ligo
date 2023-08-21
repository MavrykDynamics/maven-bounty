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
[@inline] const error_ONLY_ADMINISTRATOR_OR_SUPER_ADMINISTRATOR_ALLOWED                                                 = 31n;




// ------------------------------------------------------------------------------
//
// Bounty Errors
//
// ------------------------------------------------------------------------------

[@inline] const error_ADMINISTRATOR_NOT_FOUND                                                                           = 32n;
[@inline] const error_NOT_ADMIN                                                                                         = 33n;
[@inline] const error_NO_NEW_SUPER_ADMIN_FOUND                                                                          = 34n;
[@inline] const error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                     = 35n;

[@inline] const error_ONLY_ADMINISTRATOR_OR_BOUNTY_CREATOR_ALLOWED                                                      = 36n;
[@inline] const error_ONLY_ADMIN_OR_CREATOR_OR_WHITELISTED_ALLOWED                                                      = 37n;
[@inline] const error_SENDER_IS_NOT_GROUP_CREATOR                                                                       = 38n;
[@inline] const error_SENDER_IS_NOT_APPLICANT                                                                           = 39n;

[@inline] const error_INVALID_STATUS                                                                                    = 40n;
[@inline] const error_INVALID_STATUS_FOR_BOUNTY_REVIEW                                                                  = 41n;

[@inline] const error_MILESTONE_REWARDS_AND_TOTAL_REWARDS_DO_NOT_TALLY                                                  = 42n;
[@inline] const error_BOUNTY_RECORD_NOT_FOUND                                                                           = 43n;
[@inline] const error_MILESTONES_FOR_BOUNTY_NOT_FOUND                                                                   = 44n;
[@inline] const error_APPLICATION_RECORD_NOT_FOUND                                                                      = 45n;
[@inline] const error_USER_RECORD_NOT_FOUND                                                                             = 46n;
[@inline] const error_GROUP_RECORD_NOT_FOUND                                                                            = 47n;
[@inline] const error_BOUNTY_CREATOR_RECORD_NOT_FOUND                                                                   = 48n;
[@inline] const error_MILESTONE_RECORD_FOR_BOUNTY_NOT_FOUND                                                             = 49n;
[@inline] const error_MILESTONE_RECORD_FOR_APPLICANT_NOT_FOUND                                                          = 50n;
[@inline] const error_MILESTONE_LOG_FOR_APPLICANT_NOT_FOUND                                                             = 51n;
[@inline] const error_MILESTONE_LOG_RECORD_NOT_FOUND_IN_APPLICANT_RECORD                                                = 52n;
[@inline] const error_USER_IS_NOT_IN_GROUP                                                                              = 53n;
[@inline] const error_USER_IS_NOT_INVITED_TO_JOIN_GROUP                                                                 = 54n;
[@inline] const error_MAX_MEMBERS_PER_GROUP_REACHED                                                                     = 55n;
[@inline] const error_MAX_GROUPS_CREATED_PER_USER_REACHED                                                               = 56n;

[@inline] const error_BOUNTY_IS_NOT_ACTIVE                                                                              = 57n;
[@inline] const error_BOUNTY_IS_PAUSED                                                                                  = 58n;
[@inline] const error_BOUNTY_HAS_NO_SPACE_FOR_NEW_APPLICANTS                                                            = 59n;
[@inline] const error_USER_HAS_NO_SPACE_FOR_NEW_BOUNTIES                                                                = 60n;
[@inline] const error_USER_HAS_REACHED_MAX_APPLICATIONS_ALLOWED                                                         = 61n;
[@inline] const error_APPLICATION_STATUS_IS_NOT_PENDING                                                                 = 62n;
[@inline] const error_BOUNTY_CANNOT_BE_STOPPED_BY_USER                                                                  = 63n;
[@inline] const error_BOUNTY_HAS_ALREADY_BEEN_COMPLETED_AND_APPROVED                                                    = 64n;
[@inline] const error_MILESTONE_NEEDS_TO_BE_SPECIFIED_FOR_REVIEW                                                        = 65n;
[@inline] const error_MILESTONE_LOG_NOT_FOUND_IN_APPLICANT_RECORD                                                       = 66n;
[@inline] const error_CURRENT_MILESTONE_NOT_FOUND                                                                       = 67n;
[@inline] const error_MILESTONE_TO_REVIEW_NEEDS_TO_BE_THE_SAME_AS_CURRENT_MILESTONE                                     = 68n;
[@inline] const error_BOUNTY_HAS_REACHED_MAX_APPROVED_APPLICANTS                                                        = 69n;
[@inline] const error_BOUNTY_HAS_NO_MILESTONES                                                                          = 70n;
[@inline] const error_MILESTONE_NEEDS_TO_BE_SPECIFIED_TO_SEND_BOUNTY_REWARD                                             = 71n;
[@inline] const error_USER_HAS_ALREADY_APPLIED_FOR_THIS_BOUNTY                                                          = 72n;

[@inline] const error_SET_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                   = 73n;
[@inline] const error_TOGGLE_PAUSE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                          = 74n;
[@inline] const error_APPROVE_OR_REJECT_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                            = 75n;
[@inline] const error_REVIEW_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                = 76n;
[@inline] const error_SEND_BOUNTY_REWARD_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                           = 77n;
[@inline] const error_APPLY_FOR_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                             = 78n;
[@inline] const error_CANCEL_APPLICATION_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                           = 79n;
[@inline] const error_COMPLETE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                              = 80n;
[@inline] const error_STOP_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                  = 81n;
[@inline] const error_FORM_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                   = 82n;
[@inline] const error_ADD_GROUP_MEMBER_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                             = 83n;
[@inline] const error_CONFIRM_GROUP_MEMBERSHIP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                     = 84n;
[@inline] const error_LEAVE_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                  = 85n;
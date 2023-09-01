





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
error_ONLY_ADMINISTRATOR_OR_SUPER_ADMINISTRATOR_ALLOWED                                                 = 31










error_ADMINISTRATOR_NOT_FOUND                                                                           = 32
error_NOT_ADMIN                                                                                         = 33
error_NO_NEW_SUPER_ADMIN_FOUND                                                                          = 34
error_SENDER_IS_NOT_NEW_SUPER_ADMIN                                                                     = 35

error_ONLY_ADMINISTRATOR_OR_BOUNTY_CREATOR_ALLOWED                                                      = 36
error_ONLY_ADMIN_OR_CREATOR_OR_WHITELISTED_ALLOWED                                                      = 37
error_SENDER_IS_NOT_GROUP_CREATOR                                                                       = 38
error_SENDER_IS_NOT_APPLICANT                                                                           = 39

error_INVALID_STATUS                                                                                    = 40
error_INVALID_STATUS_FOR_BOUNTY_REVIEW                                                                  = 41

error_MILESTONE_REWARDS_AND_TOTAL_REWARDS_DO_NOT_TALLY                                                  = 42
error_BOUNTY_RECORD_NOT_FOUND                                                                           = 43
error_MILESTONES_FOR_BOUNTY_NOT_FOUND                                                                   = 44
error_APPLICATION_RECORD_NOT_FOUND                                                                      = 45

error_USER_RECORD_NOT_FOUND                                                                             = 46
error_GROUP_RECORD_NOT_FOUND                                                                            = 47
error_BOUNTY_CREATOR_RECORD_NOT_FOUND                                                                   = 48
error_MILESTONE_RECORD_FOR_BOUNTY_NOT_FOUND                                                             = 49
error_MILESTONE_RECORD_FOR_APPLICANT_NOT_FOUND                                                          = 50
error_MILESTONE_LOG_FOR_APPLICANT_NOT_FOUND                                                             = 51
error_MILESTONE_LOG_RECORD_NOT_FOUND_IN_APPLICANT_RECORD                                                = 52
error_USER_IS_NOT_IN_GROUP                                                                              = 53
error_USER_IS_NOT_INVITED_TO_JOIN_GROUP                                                                 = 54
error_MAX_MEMBERS_PER_GROUP_REACHED                                                                     = 55
error_MAX_GROUPS_CREATED_PER_USER_REACHED                                                               = 56

error_BOUNTY_IS_NOT_ACTIVE                                                                              = 57
error_BOUNTY_IS_PAUSED                                                                                  = 58
error_BOUNTY_HAS_NO_SPACE_FOR_NEW_APPLICANTS                                                            = 59
error_USER_HAS_NO_SPACE_FOR_NEW_BOUNTIES                                                                = 60
error_USER_HAS_REACHED_MAX_APPLICATIONS_ALLOWED                                                         = 61
error_APPLICATION_STATUS_IS_NOT_PENDING                                                                 = 62
error_BOUNTY_CANNOT_BE_STOPPED_BY_USER                                                                  = 63
error_BOUNTY_HAS_ALREADY_BEEN_COMPLETED_AND_APPROVED                                                    = 64
error_MILESTONE_NEEDS_TO_BE_SPECIFIED_FOR_REVIEW                                                        = 65
error_MILESTONE_LOG_NOT_FOUND_IN_APPLICANT_RECORD                                                       = 66
error_CURRENT_MILESTONE_NOT_FOUND                                                                       = 67
error_MILESTONE_TO_REVIEW_NEEDS_TO_BE_THE_SAME_AS_CURRENT_MILESTONE                                     = 68
error_BOUNTY_HAS_REACHED_MAX_APPROVED_APPLICANTS                                                        = 69
error_BOUNTY_HAS_NO_MILESTONES                                                                          = 70
error_BOUNTY_CANNOT_BE_COMPLETED                                                                        = 71
error_BOUNTY_IS_ALREADY_PENDING_REVIEW                                                                  = 72
error_MILESTONE_NEEDS_TO_BE_SPECIFIED_TO_SEND_BOUNTY_REWARD                                             = 73
error_USER_HAS_ALREADY_APPLIED_FOR_THIS_BOUNTY                                                          = 74
error_GROUP_CREATOR_CANNOT_REMOVE_HIMSELF                                                               = 75

error_SET_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                   = 76
error_TOGGLE_PAUSE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                          = 77
error_APPROVE_OR_REJECT_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                            = 78
error_REVIEW_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                = 79
error_SEND_BOUNTY_REWARD_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                           = 80
error_APPLY_FOR_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                             = 81
error_CANCEL_APPLICATION_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                           = 82
error_COMPLETE_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                              = 83
error_STOP_BOUNTY_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                  = 84
error_FORM_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                   = 85
error_ADD_GROUP_MEMBER_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                             = 86
error_CONFIRM_GROUP_MEMBERSHIP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                     = 87
error_LEAVE_GROUP_ENTRYPOINT_IN_BOUNTY_CONTRACT_PAUSED                                                  = 88

error_MEMBER_DID_NOT_APPLY_FOR_GROUP                                                                    = 89
error_SENDER_IS_ALREADY_GROUP_MEMBER                                                                    = 90

error_GROUP_CREATOR_CANNOT_APPLY_FOR_HIS_OWN_GROUP                                                      = 91
error_GROUP_CREATOR_CANNOT_INVITE_HIMSELF                                                               = 92
error_GROUP_HAS_A_BOUNTY_IN_PROGRESS                                                                    = 93

error_BOUNTY_APPLICATION_NEEDS_TO_BE_APPROVED_FIRST                                                     = 94
error_BOUNTY_APPLICATION_HAS_ALREADY_STOPPED                                                            = 95
error_BOUNTY_APPLICATION_IS_STOPPED_AND_CANNOT_BE_COMPLETED                                             = 96
error_BOUNTY_HAS_ALREADY_BEEN_COMPLETED                                                                 = 97
error_BOUNTY_APPLICATION_IS_ALREADY_PENDING_REVIEW                                                      = 98
error_APPLICATION_IS_CANCELED                                                                           = 99
error_BOUNTY_REVIEW_IS_NOT_APPROVED                                                                     = 100


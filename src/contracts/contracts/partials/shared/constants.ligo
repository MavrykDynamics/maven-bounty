// ------------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------------

// fixed point accuracy for calculations - 1e36
const fixedPointAccuracy : nat = 1_000_000_000_000_000_000_000_000_000n // 10^27

// for entries where a default address is required
const zeroAddress : address = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address);

// zero timestamp
const zeroTimestamp : timestamp = ("1970-01-01t00:00:00Z" : timestamp);

// time constants
const one_day        : int  = 86_400;           // seconds in a day
const thirty_days    : int  = one_day * 30;     // seconds in 30 days

const secondsInYear  : nat   = 31_536_000n;  // 365 days
# OTOKEN: FINAL REVIEW NOTES

## General:

- Standardise pragmas across all of our files to ^0.8.19
- contractHasTokens modifier is only used once in each exercise, should be moved to BaseExercise
- if not moved to base, check if a modifier has any gas disadvantages to a standard if statement check

## SablierStreamCreator.sol

- Remappings to be cleand up
- Is there a way to remove the Linear and create everything with Dynamic?
- We may want to set 'cancellable' to be false - think about this? (It might seem to people like we can cancel their reward streams)
- lines 76 & 104: do we need to zero out the token approval? Remove from both Sablier functions.
- line 125: Move segmentAmount up to the uint256 calcs above the for loop (line 122)

## FixedExercise.sol

- Remove the credit system
- Remove multiplier entirely - just set the price at whatever it should be (including the discount)
- line143: setPrice function to check against zero
- lines 180 & 181: Remove maxPaymentAmount & it's check (not need, no oracle called)
- line 13: Remove maxPaymentAmount from FixedExerciseParams struct

## LockedLPExercise.sol

- line 17: remove the IPair interface
- line 86: remove commented out 'pair' address variable
- Add Note: LockedLPExercise contract is tested against Thena on BNB Chain.
- Multiplier Variables:
  - maxMultiplier and minMultiplier should be constants (lines 96 & 97)
  - maxMultiplier and minMultiplier should be renamed to something clear
  - Contract MAX and MIN Multipliers:
    - maxMultiplier should be something like: 1000 (90% off)
    - minMultiplier should be something like: 20000 (100% premium, i.e. negative discount)
  - Constructor:
    - maxMultiplier and minMultiplier to be set in the constructor
    - checks to be put in place to check the constructor max/min against the constant ones
  - Setter:
    - setMultipliers (onlyOwner) to be added
- Duration Variables:
  - should follow the same format (constants, constructor-set, and setter available) as for the multipliers
- Should we distribute fees befoer or after the LP is created? (Yes, we should, seems to be the consensus)
- View function required for the frontend to query how much a user has to pay

## VestedExercise.sol

- Same as with the LockedLPExercise, constants to be set for the upper and lower bounds of the vestDuration (e.g. 1 week - 4 years)
- then vestDurations should be settable in constructor (and later via a setter function)
- line 106: remove the second "emit SetOracle"
- getLockDurationFromDiscount
  - don't rely on this without explaining exactly how it's working
  - can the ints be changed to uints in this function (what was the error)

## CustomStreamExercise.sol

- line 108: remove the second "emit SetOracle"
- line 138: move the segmentExponents length check into the internal exercise function
- lines 187 - 190: the multiplier range check here is how the checks should work on the other contract setters
- line 217: change revert error Exercise RequestedAmountTooHigh() to same as DiscountExercise contract - Exercise SlippageTooHigh()

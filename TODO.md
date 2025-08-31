# TODO

- re-work donated royalties: track payouts but pay to org instead
- fix nginx client body size - distrokid uploads too big, setting didnt work
- mobile friendly for tables
- Patreon


[Phase 4 - additional features]
- better parsing of credits: instead of markdown, links to twitter,etc
- allow artist to see their own payee info
- allow payees to forward their contributions to another payee (rebuild opt-out around this using forwards to FS-000)
- Alternate display currencies (still paid out in single currency)
- artist contributions outside of splits
- artist images
- Allow Artist to edit their own profile and see their payouts
- Public content: view Projects, Tracks, Artist profile
- Bandcamp integration - auto-import sales (or button to upload report)
- Distrokid integration - auto-import sales (or button to upload report)
- Paypal integration - issue payments (after manual review)

-----


# weird exceptions

skip splits
      - ron monstera (fundamentals)
      - Unnamed Gender Chores Release
      - ashes
      - My Baby Wouldn't Pass a Turing Test

limiter-released - >2 tracks limiter released and in the feedback. added manually
ron monstera (fundamentals) -> track by ethan geller 

mike townsend trilogy remapped to quintilogy

skip bandcamp
    - https://garlicbreadandroses.bandcamp.com/album/take-care-of-yourself 12 sales


two internal merch orders of #14 cassette have no payee??


discogs count doesn't line up 40 vs 39 (limiter?)

expenses only from album sales, not streaming? else how to divide?

expenses can come after payments have come in, causing the possibility of over-paying royalties

org takes loss on returns (very small, ~$3 distrokid, unable to identify in bandcamp)
skipping return of Back for Good (-1.0e-06)
skipping return of Burn Towns Get Money (-0.7000772)
skipping return of Boyfriend (-0.70022442)
skipping return of Dial Tone (-0.70022442)
skipping return of we are the garages (vol 4) (-0.76203553)
skipping return of bones to ohio (anyone else) (-0.01097669)


skus on home sheet don't align with bandcamp. remap document created, preferring home sheet skus


missing from bandcamp: 
https://fourth-strike.bandcamp.com/merch/fourth-strike-sticker
FSR-FSS
added manually


no exact indication of what the feb tape for patreon was.
patreon says:
2021-02-19: our cassettes for the month are in the printing process right now (no spoilers, but it's a long overdue tape)
2021-04-20: Thanks for bearing with us while we got cassette tape production under control - we caught up on February's tapes, which will be available to everyone very shortly, and have March and April's on the way.

Thus it must be one that wasn't available for sale before Feb 2020, was "long overdue" at said point, couldn't have been sold on bandcamp
until around April of 2020, and wasn't sold as one of the other months. Based on these clues, my best guess is it was away games, which
was released in Oct 2020 but wasn't for sale as a tape until April 2021.

      C-WTB-001 sept 2020
      C-WTB-002 dec 2020
      C-REV-001 dec 2020
      C-ENC-001 sept 2020
      C-ENC-002 
C-AWY-001 april 2021 :thinking:
      C-STM-001 sold in dec 2020
      C-DEI-001 sold in oct 2020
      C-LVB-001 [march]
      C-BOB-001 sold in nov 2020
      C-NEO-001 [jan]
      C-14+-001 [april]
      C-BTM-001 was a CD, not a tape
      C-CON-001 [may]
      C-TPH-001 [june]


(no spoilers, but it's a long overdue tape),

How to handle forwards, e.g. rolo -> jen, INOM -> fs? Just paypal info, or explicit feature?


    # TG-PCBO: C-BOB-001 # CASSETTE, ''BLATTLE OF THE BLANDS''
    # TG-NF-PCN0: C-NEO-001 # neon fakes
    # C-14+: C-14+-001 # #14
    # TG-WATB: T-WTB # We are the band tee
    # TG-D8T: T-DEI-80 # DEICIDE - 80s TEE
    # TG-KTG8: T-KTG-80 # KILL THE GODS - 80s TEE
    # CON-001: C-CON-001 # CONSUMED – CASSETTE, CON-001 
    # C-WTB-001: C-WTB-002
    # T-UNDG: TG-UTP
    # P-UNDG: P-UND
    # T-DB22: FSR-DB22
    # T-LADB: TG-LDBF # LIVE @ DESERT BUS FOR HOPE
    # T-SGL: TG-SGLT # SEATTLE GARAGES LOGO TEE
    # T-GEC: T-GCR # ''gender chores'' - rainbow logo tee
    # FSR-002: FSR-FSS # FOURTH STRIKE STICKER # TODO: confirm
    # # BtM has weird skus on bandcamp
    # T-DST: BTM-TDOS-S # ''THE DEATHS OF SEBASTIAN TELEPHONE'' TEE
    # T-KFP: BTM-KFTP   # ''KILLER FOR THE PIES'' TEE
    # T-BHH: BTM-BHHS   # ''BRUSHED HIS HAND'' SWEATSHIRT
    # P-DST: BTM-TDOS-1 # The Deaths of Sebastian Telephone [12x12]
    # M-INE: BTM-ISNE   # ''IT'S NOT EASY'' - COLOR-CHANGING MUG
    # # same splits for both variants
    # T-GVD: [T-GVD-FIT, T-GVD-UNI]

- Re-think donations
  - how do charities work?
  - how does donating your royalties work if you've already been paid?
  - you should still be able to see your earnings even if donating
  - forwarding to another payee? jen/rolo?
  - Lamb/L@L/SigFigs?



- I should be able to donate all my royalties to the org, but I should still be able to see how much I've earned
- Need to "buy out" a contract - SigFigs, LAMB, L@L - all future funds to org
- Need to turn it on for a bit, then turn it off
- Charity - 


2nd layer of royalty calculations
  1st layer just assumes fixed royalties for everyone
  2nd layer looks at value, payee, date range, etc and updates new totals


PaymentForwardingRule
  Source: Payee
  Target: Payee (could be org)
  start_date: Date
  end_date: Date
  reason: Text
    Donation
    Contract Buyout

  def value: how much has been forwarded

optionally product-specific? allows charity to be fixed....

Album
Gross: $105
Net: $100
Splits:
  p_A: 2
  p_B: 1
  p_C: 1
Rules:
  p_B->org

Royalties:
  org: 15% -> $15
  per_split: 85%/4 -> $21.25

Earnings:
  p_A: 2*21.25 = $42.50
  p_B: $0
  p_C: $21.25
  org: 15+21.25=$36.25





For each sale, generate micro-transactions
above example (assuming one sale): 5 transactions
- sale: References
- product (copy from sale)
- Payee[index]
- amount: Money
- date (copy from sale)
- type: org_cut, artist_royalty, charity_royalty, forwarded, service_rendered


Records: 4.6*500_000 = ~2.3M
Could possibly even "check off" items as paid
This gets rid of cache and allows for more complex logic


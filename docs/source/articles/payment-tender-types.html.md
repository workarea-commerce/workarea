---
title: Payment Tender Types
excerpt: TODO
created_at: 2019/11/05
---

Payment Tender Types
======================================================================

TODO: document introduction and additional sections


Operation Implementations
----------------------------------------------------------------------

_Explain_ operation implementations here.
So that devs working through a specific tender type implementation doc (credit card, primary, advance payment) can make sense of the steps.
Provide context.

The semantics of each operation.

When each operation is triggered.

The "contract" of an operation implementation (complete/cancel, assigning a transaction response).
Look for all references to this in the 3 howto docs.

When writing an operation implementation, you "do stuff" with `transaction`, `tender`, and `options` (and credit card adds `address`), so explain what they are.

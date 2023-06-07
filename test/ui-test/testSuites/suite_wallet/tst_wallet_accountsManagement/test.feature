Feature: Status Desktop Wallet Section Wallet Account Management

    As a user I want to add edit remove different types of wallet accounts

    Background:
        Given A first time user lands on the status desktop and generates new key
        Given the user signs up with username "tester123" and password "TesTEr16843/!@00"
        And the user lands on the signed in app
        And the user opens the wallet section
        And the user accepts the signing phrase

    Scenario Outline: The user edits default wallet account
        When the user selects wallet account with "<name>"
        And the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list
        Examples:
            | name           | new_name         | new_color | new_emoji  | new_emoji_unicode |
            | Status account | MyPrimaryAccount | 216266    | sunglasses | 1f60e             |

        Scenario Outline: The user manages a watch only account
        When the user adds a watch only account "<address>" with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list
        When the user removes account "<new_name>"
        Then the account with "<new_name>" is not displayed
        Examples:
            | address                                    | name      | color  | emoji      | emoji_unicode | add_via_context_menu | new_name        | new_color | new_emoji | new_emoji_unicode |
            | 0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A | AccWatch1 | 2a4af5 | sunglasses | 1f60e         | yes                  | AccWatch1edited | 216266    | thumbsup  | 1f44d             |
            | 0xea123F7beFF45E3C9fdF54B324c29DBdA14a639B | AccWatch2 | 7140fd | sunglasses | 1f60e         | no                   | AccWatch2edited | 2a799b    | thumbsup  | 1f44d             |

        Scenario Outline: The user cancel deliting watch only account
        When the user adds a watch only account "<address>" with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user start removing account "<name>" and cancel it
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        Examples:
            | address                                    | name      | color  | emoji      | emoji_unicode |
            | 0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A | AccWatch1 | 2a4af5 | sunglasses | 1f60e         |


        Scenario Outline: The user manages a generated account
        When the user adds a generated account with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list
        When the user removes account "<new_name>" with agreement
        Then the account with "<new_name>" is not displayed

        Examples:
            | name    | color  | emoji      | emoji_unicode | add_via_context_menu | new_name      | new_color | new_emoji | new_emoji_unicode |
            | GenAcc1 | 2a4af5 | sunglasses | 1f60e         | yes                  | GenAcc1edited | 216266    | thumbsup  | 1f44d             |
            | GenAcc2 | 7140fd | sunglasses | 1f60e         | no                   | GenAcc2edited | 2a799b    | thumbsup  | 1f44d             |


        Scenario Outline: The user cancel deliting generated account
        When the user adds a generated account with "<name>" color "#<color>" and emoji "<emoji>" via "<add_via_context_menu>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user start removing account "<name>" and cancel it
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        Examples:
            | name    | color  | emoji      | emoji_unicode | add_via_context_menu |
            | GenAcc1 | 2a4af5 | sunglasses | 1f60e         | yes                  |

        Scenario Outline: The user manages a custom generated account
        When the user adds a custom generated account with "<name>" color "#<color>" emoji "<emoji>" and derivation "<path>" "<address_index>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user removes account "<name>" with agreement
        Then the account with "<name>" is not displayed

        Examples:
            | address_index | path                           | name          | color  | emoji      | emoji_unicode |
            | 5             | Ethereum                       | CustomGenAcc1 | 216266 | sunglasses | 1f60e         |
            | 10            | Ethereum Testnet (Ropsten)     | CustomGenAcc2 | 7140fd | sunglasses | 1f60e         |
            | 15            | Ethereum (Ledger)              | CustomGenAcc3 | 2a799b | sunglasses | 1f60e         |
            | 20            | Ethereum (Ledger Live/KeepKey) | CustomGenAcc4 | 7140fd | sunglasses | 1f60e         |
            | 95            | N/A                            | CustomGenAcc1 | 216266 | sunglasses | 1f60e         |


        Scenario Outline: The user manages a private key imported account
        When the user adds a private key account "<private_key>" with "<name>" color "#<color>" and emoji "<emoji>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list
        When the user removes account "<new_name>"
        Then the account with "<new_name>" is not displayed

        Examples:
            | private_key                                                      | name        | color  | emoji      | emoji_unicode | new_name          | new_color | new_emoji | new_emoji_unicode |
            | 2daa36a3abe381a9c01610bf10fda272fbc1b8a22179a39f782c512346e3e470 | PrivKeyAcc1 | 2a4af5 | sunglasses | 1f60e         | PrivKeyAcc1edited | 216266    | thumbsup  | 1f44d             |

        Scenario Outline: The user manages a seed phrase imported account
        When the user adds an imported seed phrase account "<seed_phrase>" with "<name>" color "#<color>" and emoji "<emoji>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list
        When the user removes account "<new_name>" with agreement
        Then the account with "<name>" is not displayed

        Examples:
            | seed_phrase                                                                                                                                                   | name    | color  | emoji      | emoji_unicode | new_name      | new_color | new_emoji | new_emoji_unicode |
            | elite dinosaur flavor canoe garbage palace antique dolphin virtual mixed sand impact solution inmate hair pipe affair cage vote estate gloom lamp robust like | SPAcc24 | 2a4af5 | sunglasses | 1f60e         | SPAcc24edited | 216266    | thumbsup  | 1f44d             |
            | kitten tiny cup admit cactus shrug shuffle accident century faith roof plastic beach police barely vacant sign blossom                                        | SPAcc18 | 2a4af5 | sunglasses | 1f60e         | SPAcc18edited | 216266    | thumbsup  | 1f44d             |
            | pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial                                                                               | SPAcc12 | 2a4af5 | sunglasses | 1f60e         | SPAcc12edited | 216266    | thumbsup  | 1f44d             |

        Scenario Outline: The user manages an account created from the imported seed phrase
        When the user adds an imported seed phrase account "pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial" with "SPAcc12" color "#2a4af5" and emoji "sunglasses"
        Then the account with "SPAcc12" is displayed
        When the user adds to "pcsomrselw" a custom generated account with "<name>" color "#<color>" emoji "<emoji>" and derivation "<path>" "<address_index>"
        And the user removes account "<name>" with agreement
        Then the account with "<name>" is not displayed

        Examples:
            | address_index | path                           | name          | color  | emoji      |
            | 5             | Ethereum                       | CustomGenAcc1 | 216266 | sunglasses |
            | 10            | Ethereum Testnet (Ropsten)     | CustomGenAcc2 | 7140fd | sunglasses |
            | 15            | Ethereum (Ledger)              | CustomGenAcc3 | 2a799b | sunglasses |
            | 20            | Ethereum (Ledger Live/KeepKey) | CustomGenAcc4 | 7140fd | sunglasses |
            | 95            | N/A                            | CustomGenAcc1 | 216266 | sunglasses |


        Scenario Outline: The user adds and edits an account from the generated seed phrase
        When the user adds a generated seed phrase account with "<name>" color "#<color>" emoji "<emoji>" and keypair "<keypair_name>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user edits an account with "<name>" to "<new_name>" with color "#<new_color>" and emoji "<new_emoji>"
        Then the account is correctly displayed with "<new_name>" and "#<new_color>" and emoji unicode "<new_emoji_unicode>" in accounts list

        Examples:
            | keypair_name | name  | color  | emoji      | emoji_unicode | new_name     | new_color | new_emoji | new_emoji_unicode |
            | SPKeyPair    | SPAcc | 2a4af5 | sunglasses | 1f60e         | SPAcc_edited | 216266    | thumbsup  | 1f44d             |

        Scenario Outline: The user manages an account created from the generated seed phrase
        When the user adds a generated seed phrase account with "SPKeyPair" color "#<color>" emoji "<emoji>" and keypair "<keypair_name>"
        Then the account with "SPKeyPair" is displayed
        When the user adds to "<keypair_name>" a custom generated account with "<name>" color "#<color>" emoji "<emoji>" and derivation "<path>" "<address_index>"
        Then the account is correctly displayed with "<name>" and "#<color>" and emoji unicode "<emoji_unicode>" in accounts list
        When the user removes account "<name>" with agreement
        Then the account with "<name>" is not displayed
        Examples:
            | address_index | path                           | name          | color  | emoji      | emoji_unicode | keypair_name |
            | 5             | Ethereum                       | CustomGenAcc1 | 216266 | sunglasses | 1f60e         | SPKeyPair    |
            | 10            | Ethereum Testnet (Ropsten)     | CustomGenAcc2 | 7140fd | sunglasses | 1f60e         | SPKeyPair    |
            | 15            | Ethereum (Ledger)              | CustomGenAcc3 | 2a799b | sunglasses | 1f60e         | SPKeyPair    |
            | 20            | Ethereum (Ledger Live/KeepKey) | CustomGenAcc4 | 7140fd | sunglasses | 1f60e         | SPKeyPair    |
            | 95            | N/A                            | CustomGenAcc1 | 216266 | sunglasses | 1f60e         | SPKeyPair    |

        @mayfail
        Scenario: The user adds an account and then decides to use a Keycard
        When the user adds new master key and go to use a Keycard
        Then settings keycard section is opened
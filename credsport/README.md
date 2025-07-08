# CredSport

**CredSport** is a decentralized smart contract system built on the Clarity language for managing sports coach credentials. It allows coaches to maintain verified coaching licenses, record team achievements, receive player testimonials, and build secure professional networks—all while controlling who can access what data through tiered permissions.

---

## 🔧 Features

- **Coach Profiles**: Coaches can create detailed profiles including their name, sport specialties, team affiliations, and access tiers.
- **Licensing Management**: Coaches can store and update coaching licenses, with optional admin verification for credibility.
- **Team Achievements**: Log and share major team achievements with tiered visibility options.
- **Player Testimonials**: Players can submit testimonials to endorse coaching skills—available only if both are in a verified network.
- **Coaching Networks**: Coaches can initiate and accept connection requests to build professional trust circles.
- **Skill Endorsements**: Tracks endorsements per coaching skill to build reputation metrics.
- **Access Tiers**: Offers flexible visibility controls: `public`, `licensed coaches`, and `private`.

---

## 📂 Data Structures

### Coach Profile
- Name
- Sport Specialties
- Team Affiliation
- Tier Level (Public, Licensed-Coaches, Private)
- Is Licensed (Boolean)

### Coaching License
- License Type
- Issuing Federation
- Issued & Renewal Dates
- License Hash (Proof)
- Tier & Verification Status

### Team Achievement
- Competition Name
- Achievement Type
- Date, Season Start
- Details
- Tier Level

### Player Testimonial
- Coaching Skill
- Recommending Player
- Testimonial Text

### Coaching Network
- Request Status (`pending`, `connected`, `inactive`)
- Initiated By
- Connected At Block Height

---

## 🛡️ Access Control

| Role          | Privileges                                 |
|---------------|---------------------------------------------|
| Coach         | Profile creation, license/achievement input |
| Player        | Testimonial submission (if networked)       |
| Admin (Owner) | License verification, coach licensing       |

---

## 🚀 Functions

### Public
- `create-coach-profile`
- `record-team-achievement`
- `add-coaching-license`
- `submit-player-testimonial`
- `send-network-request`
- `accept-network-request`

### Admin Only
- `verify-coaching-license`
- `license-coach`
- `update-coaching-fee`

---

## 📜 Access Tiers

- `TIER-PUBLIC (0)`
- `TIER-LICENSED-COACHES (1)`
- `TIER-PRIVATE (2)`

Access is determined by tier and network relationship.

---

## 🛠️ Setup & Deployment

This contract is written in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview) and is deployable on any Stacks-compatible chain like `testnet` or `mainnet`.

To deploy:
1. Clone repo
2. Use the [Stacks CLI](https://github.com/stacksjs/cli) or deploy via [Clarinet](https://docs.hiro.so/clarinet/get-started)
3. Set `contract-owner` as the deployer's address

---

## 💡 Use Cases

- Decentralized coach validation and credentialing
- Talent scouting platforms
- Sports team organization portals
- Trustless player-coach engagement systems

---

## 📄 License

MIT License

---

## 🤝 Contribution

Pull requests and feature proposals are welcome. Please ensure clarity, testability, and security in all code contributions.

---

## 🧠 Inspiration

The rise of self-sovereign identity in education and healthcare sparked the idea of decentralized trust credentials for sports coaching and talent development.

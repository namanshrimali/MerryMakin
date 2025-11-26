# Best Practices: Unauthenticated User Content Visibility
## Event Details Page - Guest List & Activity Section

### Executive Summary

This document outlines recommended best practices for what users should be able to view on event detail pages, specifically regarding the **Guest List** and **Activity Section**. The app has three distinct user states:

1. **Completely Unauthenticated**: No user account, no RSVP
2. **RSVP'd but Not Fully Authenticated**: Has user account (created during RSVP), has RSVP'd, but `isUserAuthorized() == false`
3. **Fully Authenticated**: Has user account with `ROLE_USER` authority, `isUserAuthorized() == true`

This document provides recommendations for states 1 and 2, balancing user engagement, privacy protection, and conversion optimization.

**Key Finding**: Users who RSVP'd (state 2) should see MORE than completely unauthenticated users (state 1) but LESS than fully authenticated users (state 3). This creates a progressive disclosure model that rewards engagement.

---

## 1. Guest List Section - Best Practices

### Current State Analysis
- Currently shows full guest list to all users (authorization check is commented out)
- Has `_buildUnAuthorizedGuestState` method ready but unused
- Supports `hideMode` for avatars when user is not authorized
- Has `isGuestListHidden` and `isGuestCountHidden` event-level privacy flags
- Users can RSVP without full authentication (creates user account but without `ROLE_USER`)

### User State Detection
```dart
// Check user state
final user = cookiesService.currentUser;
final isUserAuthorized = user?.isUserAuthorized() ?? false;
final hasRsvpd = user != null && 
                 event.getRsvpStatusForUser(user) != RSVPStatus.UNDECIDED;

// Three states:
// 1. Completely unauthenticated: user == null || (!isUserAuthorized && !hasRsvpd)
// 2. RSVP'd but not fully authenticated: !isUserAuthorized && hasRsvpd
// 3. Fully authenticated: isUserAuthorized
```

### Recommended Approach for Completely Unauthenticated Users (State 1)

#### ✅ **SHOULD SHOW:**
1. **Aggregated Counts Only** (if `isGuestCountHidden` is false)
   - Total number of attendees (e.g., "12 people going")
   - Breakdown by RSVP status (e.g., "8 Going • 4 Maybe")
   - This provides social proof without exposing personal information

2. **Anonymized Visual Indicators**
   - Generic avatar placeholders or silhouettes (not actual user photos)
   - Stacked avatar UI showing count without revealing identities
   - Use `hideMode: true` for all avatars shown to unauthenticated users

3. **Engagement Call-to-Action**
   - Clear message: "Sign up to see who's attending!"
   - Prominent "Sign Up" button linking to OAuth login
   - Value proposition: "Join to connect with other attendees"

#### ❌ **SHOULD NOT SHOW:**
1. **Individual User Identities**
   - No actual user names
   - No profile photos (use generic avatars/initials)
   - No ability to view full attendee list
   - No "View All" button functionality

2. **Detailed Attendee Information**
   - No plus-ones details
   - No individual RSVP status visibility
   - No ability to tap/expand guest cards

3. **Privacy-Sensitive Data**
   - Respect `isGuestListHidden` flag (if true, show even less)
   - Respect `isGuestCountHidden` flag (if true, hide counts too)

### Recommended Approach for RSVP'd Users (State 2)

**Rationale**: Users who RSVP'd have shown commitment to the event and provided their name (and optionally email). They should see more than completely unauthenticated users as a reward for engagement, but still less than fully authenticated users to encourage full sign-up.

#### ✅ **SHOULD SHOW:**
1. **Full Aggregated Counts** (if `isGuestCountHidden` is false)
   - Total number of attendees (e.g., "12 people going")
   - Breakdown by RSVP status (e.g., "8 Going • 4 Maybe")
   - Show their own RSVP status: "You're Going!" or "You're Maybe"

2. **Anonymized Guest List Preview**
   - Show first 5-8 attendees with anonymized avatars (`hideMode: true`)
   - Use initials or generic avatars (not profile photos)
   - Show stacked avatar UI indicating more attendees

3. **Limited "View All" Access**
   - Allow viewing full guest list BUT with anonymized identities
   - All names shown as "Someone" or initials only
   - All profile photos hidden (`hideMode: true` for all)
   - Show RSVP status counts but not individual statuses

4. **Encouragement to Full Sign-Up**
   - Message: "Sign up to see names and connect with attendees!"
   - Prominent "Sign Up" button linking to OAuth login
   - Value proposition: "See who's coming and join the conversation"

#### ❌ **SHOULD NOT SHOW:**
1. **Individual User Identities**
   - No actual user names (use "Someone" or initials)
   - No profile photos (use generic avatars/initials)
   - No ability to see individual RSVP statuses (only aggregated)

2. **Detailed Attendee Information**
   - No plus-ones details for other attendees
   - No email addresses or contact info
   - No ability to tap/expand guest cards to see details

3. **Privacy-Sensitive Data**
   - Respect `isGuestListHidden` flag (if true, show even less)
   - Respect `isGuestCountHidden` flag (if true, hide counts too)

### Implementation Recommendation
```dart
// Pseudocode for recommended approach
final user = cookiesService.currentUser;
final isUserAuthorized = user?.isUserAuthorized() ?? false;
final hasRsvpd = user != null && 
                 event.getRsvpStatusForUser(user) != RSVPStatus.UNDECIDED;

if (!isUserAuthorized) {
  if (event.isGuestListHidden) {
    // Show minimal: "Sign up to see guest list"
  } else if (hasRsvpd) {
    // RSVP'd users: Show counts + anonymized preview + limited "View All"
    // All avatars with hideMode: true
    // All names as "Someone" or initials
  } else {
    // Completely unauthenticated: Show counts only + anonymized avatars
    // No "View All" button
  }
  // Always show sign-up CTA (different messaging for RSVP'd users)
}
```

---

## 2. Activity Section (Comments) - Best Practices

### Current State Analysis
- Currently shows all comments to everyone
- Commenting requires authorization (correctly implemented)
- Supports `hideNames` parameter for privacy
- Comments can contain text and GIFs
- Users can RSVP without full authentication

### Recommended Approach for Completely Unauthenticated Users (State 1)

#### ✅ **SHOULD SHOW:**
1. **Limited Comment Preview**
   - Show first 2-3 most recent comments (teaser)
   - Anonymize all user information:
     - Use "Someone" instead of names (already supported via `hideNames`)
     - Use generic avatar icons instead of profile photos
     - Hide email addresses and other identifiers

2. **Comment Content (with privacy)**
   - Show comment text content (helps understand event vibe)
   - Show GIFs/images (engaging content)
   - Show relative timestamps (e.g., "2 hours ago")
   - Hide user-specific status indicators if they reveal identity

3. **Engagement Prompt**
   - Message: "Sign up to see all activity and join the conversation!"
   - "Sign Up" button prominently displayed
   - Show comment count: "X comments" (if not hidden by privacy settings)

#### ❌ **SHOULD NOT SHOW:**
1. **Full Comment Thread**
   - Limit to 2-3 comments maximum
   - Hide "View All" or pagination for unauthenticated users
   - No ability to expand full comment list

2. **User Identities**
   - Always use `hideNames: true` for unauthenticated users
   - Replace profile photos with generic icons
   - Remove any user-specific metadata

3. **Interactive Features**
   - No ability to comment (already correctly restricted)
   - No ability to delete comments
   - No ability to react/interact with comments

### Recommended Approach for RSVP'd Users (State 2)

**Rationale**: Users who RSVP'd have shown engagement and should see more activity to build excitement, but still with privacy protections to encourage full sign-up.

#### ✅ **SHOULD SHOW:**
1. **Full Comment Thread (with privacy)**
   - Show ALL comments (not limited to 2-3)
   - Anonymize all user information:
     - Use "Someone" instead of names (`hideNames: true`)
     - Use generic avatar icons instead of profile photos
     - Hide email addresses and other identifiers
   - Show comment content (text, GIFs) - helps build event excitement
   - Show relative timestamps (e.g., "2 hours ago")

2. **Their Own Activity**
   - Show their own RSVP comment/status update if they added one
   - Show it with their name (they provided it during RSVP)
   - This creates a sense of belonging and engagement

3. **Read-Only Access**
   - Can view all comments
   - Can see comment count
   - Cannot comment (requires full authentication)
   - Cannot delete or interact with comments

4. **Encouragement to Full Sign-Up**
   - Message: "Sign up to comment and see who's talking!"
   - Prominent "Sign Up" button
   - Value proposition: "Join the conversation and connect with attendees"

#### ❌ **SHOULD NOT SHOW:**
1. **User Identities (except their own)**
   - Always use `hideNames: true` for all other users
   - Replace profile photos with generic icons for others
   - Hide email addresses and other identifiers

2. **Interactive Features**
   - No ability to comment (requires full authentication)
   - No ability to delete comments
   - No ability to react/interact with comments

### Implementation Recommendation
```dart
// Pseudocode for recommended approach
final user = cookiesService.currentUser;
final isUserAuthorized = user?.isUserAuthorized() ?? false;
final hasRsvpd = user != null && 
                 event.getRsvpStatusForUser(user) != RSVPStatus.UNDECIDED;

if (!isUserAuthorized) {
  if (hasRsvpd) {
    // RSVP'd users: Show all comments with hideNames: true
    // Show their own comment with their name
    // No commenting ability
  } else {
    // Completely unauthenticated: Show 2-3 comment previews
    // All names hidden
  }
  // Show sign-up CTA (different messaging for RSVP'd users)
}
```

---

## 2.5. Special Case: Users Who RSVP'd Without Full Authentication

### The Question
**Should users who RSVP'd (provided their name) be able to view more content than completely unauthenticated users?**

### The Answer: YES - Progressive Disclosure Model

Users who RSVP'd have demonstrated commitment to the event by:
- Providing their name (required during RSVP)
- Optionally providing their email
- Committing to attend (Going/Maybe/Not Going)

**Best Practice**: Reward this engagement with enhanced access while still protecting other users' privacy and encouraging full sign-up.

### What RSVP'd Users Should See

#### Guest List Access:
1. **Full Aggregated Counts**: "12 Going • 4 Maybe" (if not hidden by privacy settings)
2. **Their Own Status**: "You're Going!" or "You're Maybe" - personal confirmation
3. **Anonymized Guest Preview**: See first 5-8 attendees with anonymized avatars
4. **Limited "View All"**: Can view full list but all names shown as "Someone" or initials
5. **No Individual Identities**: Cannot see actual names or photos of other attendees

**Rationale**: They've shown commitment, so reward them with more visibility. But still protect others' privacy and encourage full sign-up to see names.

#### Activity Section Access:
1. **Full Comment Thread**: See ALL comments (not limited preview)
2. **Their Own Activity**: See their own RSVP comment/status with their name
3. **Anonymized Others**: All other users shown as "Someone" with generic avatars
4. **Read-Only**: Can view but cannot comment (requires full authentication)

**Rationale**: Full comment visibility builds excitement and engagement. Showing their own name creates belonging. Anonymizing others protects privacy.

### Industry Examples

**Eventbrite**: Users who register can see attendee counts and some details, but full profiles require account creation.

**Facebook Events**: Users who mark "Interested" or "Going" see more event details and can see other attendees' public profiles (if public).

**Meetup**: RSVP'd members can see other members' profiles (depending on privacy settings), but full networking features require account.

**Your App's Approach**: More privacy-focused - even RSVP'd users don't see full identities until fully authenticated, which is actually a stronger privacy stance.

### Implementation Logic

```dart
// Determine user tier
final user = cookiesService.currentUser;
final isUserAuthorized = user?.isUserAuthorized() ?? false;
final hasRsvpd = user != null && 
                 event.getRsvpStatusForUser(user) != RSVPStatus.UNDECIDED;

// Three tiers:
if (isUserAuthorized) {
  // Tier 3: Full access - show everything
} else if (hasRsvpd) {
  // Tier 2: RSVP'd users - enhanced access with privacy
  // - Show counts and anonymized guest list
  // - Show full comments with anonymized names
  // - Show their own name/activity
} else {
  // Tier 1: Completely unauthenticated - minimal access
  // - Show counts only
  // - Show 2-3 comment previews
}
```

### Benefits of This Approach

1. **Rewards Engagement**: Users who RSVP feel rewarded with more access
2. **Protects Privacy**: Even RSVP'd users don't see full identities
3. **Encourages Conversion**: Natural progression: Preview → RSVP → Sign Up → Full Access
4. **Builds Trust**: Shows you care about privacy while still engaging users
5. **Compliance**: GDPR/CCPA friendly - only shows aggregated/anonymized data

### Key Principle
**"You can see more because you RSVP'd, but sign up to see everything and connect with others."**

This creates a natural conversion funnel while respecting privacy.

---

## 3. Privacy & Security Considerations

### GDPR/CCPA Compliance
- **Data Minimization**: Only show aggregated, anonymized data
- **Consent**: Require sign-up before showing personal information
- **Transparency**: Clearly communicate what data is visible to unauthenticated users
- **User Rights**: Allow users to control their visibility via `isGuestListHidden`

### Privacy Settings Hierarchy
1. **Event-Level Privacy** (`isGuestListHidden`, `isGuestCountHidden`)
   - Host can choose to hide guest list entirely
   - Should be respected for all users (authenticated and unauthenticated)

2. **User-Level Privacy** (Future consideration)
   - Allow users to opt-out of appearing in public guest lists
   - Respect user privacy preferences

3. **Platform Defaults**
   - Default to privacy-first approach
   - Show minimal information to unauthenticated users

---

## 4. User Experience & Conversion Optimization

### Engagement Strategy
1. **FOMO (Fear of Missing Out)**
   - Show aggregated counts: "15 people are going!"
   - Show activity preview: "Recent comments show excitement!"
   - Create curiosity without revealing too much

2. **Value Proposition**
   - Clear messaging: "Sign up to see who's attending and join the conversation"
   - Highlight benefits: Connect with attendees, see full activity, RSVP
   - Social proof: "Join 15+ people already attending"

3. **Friction Reduction**
   - Make sign-up process easy (OAuth integration)
   - Show value before asking for commitment
   - Provide clear path: Preview → Sign Up → Full Access

### Visual Design Recommendations
1. **Progressive Disclosure**
   - Show teaser content with blur/overlay effect
   - Use "Sign up to unlock" visual cues
   - Maintain visual consistency with authenticated view

2. **Clear CTAs**
   - Prominent "Sign Up" buttons
   - Multiple entry points (guest list + activity section)
   - Consistent styling and placement

---

## 5. Industry Benchmarks

### Similar Platforms Approach

**Eventbrite:**
- Shows attendee count to unauthenticated users
- Hides individual names until registration
- Shows limited event details

**Facebook Events:**
- Shows "X people interested/going" count
- Hides full guest list until login
- Shows public posts/comments with limited visibility

**Meetup:**
- Shows member count and organizer info
- Requires sign-up to see full attendee list
- Shows event description and basic details

**Common Pattern:**
- ✅ Aggregated counts
- ✅ Anonymized indicators
- ❌ Individual identities
- ✅ Sign-up prompts

---

## 6. Recommended Implementation Priority

### Phase 1: Core Privacy (High Priority)
1. Hide individual user identities in guest list for unauthenticated users
2. Use anonymized avatars (`hideMode: true`)
3. Show aggregated counts only (if not hidden by privacy settings)
4. Implement sign-up CTA in guest list section

### Phase 2: Activity Privacy (High Priority)
1. Limit comment preview to 2-3 comments
2. Always use `hideNames: true` for unauthenticated users
3. Use generic avatars for comment authors
4. Add sign-up CTA in activity section

### Phase 3: Enhanced UX (Medium Priority)
1. Add visual indicators (blur effects, "Sign up to unlock" overlays)
2. Improve messaging and value propositions
3. A/B test different CTA placements and copy

### Phase 4: Advanced Features (Low Priority)
1. Progressive disclosure animations
2. Personalized sign-up prompts based on event type
3. Analytics tracking for conversion optimization

---

## 7. Edge Cases & Special Considerations

### Public vs. Private Events
- **Public Events**: Show more aggregated info (counts, previews)
- **Private Events**: Show even less, require sign-up for any details
- Consider adding `isPublic` flag to Event model

### Event Host Preferences
- Respect `isGuestListHidden` flag (host choice)
- Respect `isGuestCountHidden` flag (host choice)
- Allow hosts to customize unauthenticated view

### Empty States
- If no guests: Show "Be the first to RSVP!" message
- If no comments: Show "Be the first to comment!" message
- Always provide clear next action (sign up or share)

---

## 8. Summary of Recommendations

### Three-Tier Access Model

#### Tier 1: Completely Unauthenticated Users
**Guest List:**
- ✅ Show aggregated counts only (if not hidden)
- ✅ Show anonymized avatar indicators (no names/photos)
- ✅ Show sign-up CTA
- ❌ Hide individual names and photos
- ❌ Hide detailed attendee information
- ❌ Disable "View All" functionality

**Activity Section:**
- ✅ Show 2-3 comment previews
- ✅ Show comment content (text, GIFs)
- ✅ Hide all user identities (`hideNames: true`)
- ✅ Show sign-up CTA
- ❌ Hide full comment thread
- ❌ Disable commenting functionality

#### Tier 2: RSVP'd but Not Fully Authenticated Users
**Guest List:**
- ✅ Show full aggregated counts (if not hidden)
- ✅ Show their own RSVP status ("You're Going!")
- ✅ Show anonymized guest list preview (5-8 attendees)
- ✅ Allow "View All" with anonymized identities
- ✅ Show sign-up CTA (different messaging)
- ❌ Hide individual names and photos (use "Someone" or initials)
- ❌ Hide detailed attendee information for others

**Activity Section:**
- ✅ Show ALL comments (full thread)
- ✅ Show their own comment/activity with their name
- ✅ Show comment content (text, GIFs) for all
- ✅ Hide all other user identities (`hideNames: true`)
- ✅ Show sign-up CTA (different messaging)
- ❌ Disable commenting functionality (requires full auth)

#### Tier 3: Fully Authenticated Users
**Guest List:**
- ✅ Full access to all guest information
- ✅ See all names, photos, RSVP statuses
- ✅ Full "View All" functionality
- ✅ All interactive features

**Activity Section:**
- ✅ Full access to all comments
- ✅ See all user names and photos
- ✅ Can comment and interact
- ✅ All interactive features

### Key Principles:
1. **Privacy First**: Protect user data, show only aggregated/anonymized info
2. **Engagement Second**: Use teasers to encourage sign-up
3. **Respect Settings**: Honor event-level privacy flags
4. **Clear Value**: Communicate benefits of signing up
5. **Compliance**: Follow GDPR/CCPA guidelines

---

## 9. Testing Recommendations

### User Testing Scenarios:
1. Completely unauthenticated user views public event
2. Completely unauthenticated user views private event
3. User RSVP's without full authentication → views event (Tier 2 access)
4. RSVP'd user views event with `isGuestListHidden = true`
5. RSVP'd user views event with no guests/comments
6. Conversion funnel: Preview → RSVP → Sign Up → Full Access
7. User who RSVP'd sees their own name/activity but others anonymized

### Metrics to Track:
- Sign-up conversion rate from event detail page
- Time spent on page for unauthenticated users
- Click-through rate on sign-up CTAs
- Bounce rate for unauthenticated users

---

## Conclusion

The recommended **three-tier progressive disclosure model** balances privacy protection with user engagement:

1. **Completely Unauthenticated (Tier 1)**: Minimal access - counts and previews only
2. **RSVP'd but Not Fully Authenticated (Tier 2)**: Enhanced access - full counts, anonymized guest list, full comment thread
3. **Fully Authenticated (Tier 3)**: Full access - all information visible

### Key Benefits:
- **Rewards Engagement**: Users who RSVP see more, encouraging them to RSVP
- **Protects Privacy**: Even RSVP'd users don't see full identities until fully authenticated
- **Encourages Conversion**: Progressive disclosure creates natural path to full sign-up
- **GDPR/CCPA Compliant**: Only shows aggregated/anonymized data until full consent
- **Positive UX**: Users feel rewarded for engagement while maintaining privacy

### Implementation Notes:
The current codebase already has most infrastructure in place:
- `hideMode` for avatars
- `hideNames` for comments
- `isGuestListHidden` and `isGuestCountHidden` flags
- `_buildUnAuthorizedGuestState` method
- `event.getRsvpStatusForUser()` to check RSVP status
- `user.isUserAuthorized()` to check full authentication

### Main Changes Needed:
1. Enable authorization checks (currently commented out)
2. Implement three-tier visibility logic:
   - Check `isUserAuthorized` for Tier 3
   - Check `hasRsvpd` for Tier 2
   - Default to Tier 1 for everyone else
3. Add appropriate CTAs with different messaging for each tier
4. Show RSVP'd users their own name/activity while anonymizing others

---

*Document created: Based on industry best practices, privacy regulations, and analysis of current codebase implementation.*


/// Centralised user-facing strings grouped by feature.
/// Replace inline string literals with `AppStrings.<feature>.<name>`.
abstract final class AppStrings {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const authLogin = 'Log in';
  static const authSignup = 'Sign up';
  static const authForgotPassword = 'Forgot Password?';
  static const authResetPassword = 'Reset Password';
  static const authVerifyOtp = 'Verify OTP';
  static const authEmailHint = 'name@example.com';
  static const authPasswordHint = 'Password';
  static const authUsernameHint = 'John Doe';
  static const authConfirmPasswordHint = 'Confirm Password';
  static const authNoAccount = "Don't have an account?";
  static const authHaveAccount = 'Already have an account?';

  // ── Home ──────────────────────────────────────────────────────────────────
  static const homeTitle = 'Jobs you might like';
  static const homeNoResults = 'No jobs match your search.';
  static const homeNewThisWeek = 'New this week';
  static const homeTopPick = 'Top Pick for you';

  // ── Search ────────────────────────────────────────────────────────────────
  static const searchHint = 'Search jobs, companies…';
  static const searchRecent = 'Recent searches';
  static const searchTrending = 'Trending';
  static const searchClearAll = 'Clear all';
  static const searchNoResultsPrefix = 'No jobs found for';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const profileTitle = 'Profile';
  static const profileEdit = 'Edit Profile';
  static const profileAbout = 'About';
  static const profileExperience = 'Experience';
  static const profileSkills = 'Skills';
  static const profilePortfolio = 'Portfolio';
  static const profileSaved = 'Saved';
  static const profileApplied = 'Applied';
  static const profileCvReady = 'CV ready';
  static const profileFollowing = 'Following';

  // ── Job Detail ────────────────────────────────────────────────────────────
  static const jobApply = 'Apply for this job';
  static const jobApplied = 'Applied';
  static const jobReadMore = 'Read more';
  static const jobReadLess = 'Read less';
  static const jobSave = 'Save';
  static const jobUnsave = 'Unsave';
  static const jobShare = 'Share';
  static const jobReport = 'Report';
  static const jobNotInterested = 'Not interested';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const settingsTitle = 'Settings';
  static const settingsAccount = 'Account';
  static const settingsAppearance = 'Appearance';
  static const settingsSecurity = 'Security';
  static const settingsSupport = 'Support';
  static const settingsAbout = 'About';
  static const settingsSignOut = 'Sign out';
  static const settingsSignOutConfirm = 'Are you sure you want to sign out?';
  static const settingsVersion = 'Version 1.0.0';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notificationsTitle = 'Notifications';
  static const notificationsEmpty = 'No notifications yet';
  static const notificationsMarkAllRead = 'Mark all read';

  // ── Saved Jobs ────────────────────────────────────────────────────────────
  static const savedJobsTitle = 'Saved Jobs';
  static const savedJobsEmpty = 'No saved jobs yet';
  static const savedJobsEmptyHint = 'Jobs you save will appear here.';

  // ── Applications ──────────────────────────────────────────────────────────
  static const applicationsTitle = 'Applications';
  static const applicationsEmpty = 'No applications yet';
  static const applicationsEmptyHint = 'Jobs you apply to will appear here.';

  // ── AI Chat ───────────────────────────────────────────────────────────────
  static const chatTitle = 'AI Chat';
  static const chatHint = 'Type a message…';
  static const chatNewChat = 'New chat';
  static const chatHistory = 'Chat history';

  // ── CV Builder ────────────────────────────────────────────────────────────
  static const cvTitle = 'CV Builder';
  static const cvGenerate = 'Generate CV';
  static const cvDownload = 'Download PDF';
  static const cvShare = 'Share CV';
  static const cvPreview = 'Preview CV';
  static const cvBuildPrompt = 'Build your CV';

  // ── Empty states ──────────────────────────────────────────────────────────
  static const emptyRecruiterMessages = 'No recruiter messages';
  static const emptyInterviewActivity = 'No interview activity yet';
  static const emptySearchResults = 'No results found';

  // ── Common buttons / actions ──────────────────────────────────────────────
  static const btnCancel = 'Cancel';
  static const btnConfirm = 'Confirm';
  static const btnDone = 'Done';
  static const btnSave = 'Save';
  static const btnDelete = 'Delete';
  static const btnRetry = 'Try again';
  static const btnUndo = 'Undo';
  static const btnSkip = 'Skip';
  static const btnNext = 'Next';
  static const btnBack = 'Back';
  static const btnClear = 'Clear';
  static const btnRemove = 'Remove';
  static const btnChoose = 'Choose';

  // ── Dialog text ───────────────────────────────────────────────────────────
  static const discardChangesTitle = 'Discard changes?';
  static const discardChangesBody =
      'You have unsaved changes that will be lost.';
  static const discardDraftTitle = 'Discard draft?';
  static const discardDraftBody = 'Your CV draft will be lost.';
  static const discardReportTitle = 'Discard report?';
  static const discardReportBody = 'Your report will be discarded.';
}

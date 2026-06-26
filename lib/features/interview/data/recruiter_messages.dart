/// A reusable professional message template for job seekers.
class RecruiterMessage {
  const RecruiterMessage({
    required this.title,
    required this.category,
    required this.body,
  });

  final String title;
  final String category;
  final String body;

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'body': body,
  };

  factory RecruiterMessage.fromJson(Map<String, dynamic> json) =>
      RecruiterMessage(
        title: json['title'] as String,
        category: json['category'] as String,
        body: json['body'] as String,
      );
}

const List<RecruiterMessage> recruiterMessages = [
  RecruiterMessage(
    title: 'Application follow-up',
    category: 'Follow-up',
    body:
        'Hi [Recruiter Name],\n\n'
        'I recently applied for the [Job Title] role at [Company] and wanted '
        'to reaffirm my strong interest. With my background in [skill/area], '
        'I believe I could make a meaningful contribution to your team.\n\n'
        'I would welcome the chance to discuss how my experience aligns with '
        'your needs. Thank you for your time and consideration.\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Connecting on LinkedIn',
    category: 'Networking',
    body:
        'Hi [Recruiter Name],\n\n'
        'I came across your profile while researching opportunities at '
        '[Company]. I am a [Your Role] with experience in [area] and admire '
        'the work your team is doing. I would love to connect and stay in '
        'touch about current or future openings.\n\n'
        'Thank you,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Inquiry about open roles',
    category: 'Inquiry',
    body:
        'Hi [Recruiter Name],\n\n'
        'I am very interested in joining [Company] as a [Job Title]. Could '
        'you let me know whether there are any current or upcoming openings '
        'that match my background in [skill/area]?\n\n'
        'I have attached my resume for your reference and am happy to share '
        'more details. Thank you for your help.\n\n'
        'Best,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Thank you after interview',
    category: 'Thank-you',
    body:
        'Hi [Interviewer Name],\n\n'
        'Thank you for taking the time to speak with me today about the '
        '[Job Title] role. I enjoyed learning more about [specific topic '
        'discussed] and am even more excited about the opportunity.\n\n'
        'Please let me know if there is anything else I can provide. I look '
        'forward to the next steps.\n\n'
        'Warm regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Checking on application status',
    category: 'Follow-up',
    body:
        'Hi [Recruiter Name],\n\n'
        'I hope you are doing well. I wanted to kindly follow up on my '
        'application for the [Job Title] role submitted on [date]. I remain '
        'very enthusiastic about the opportunity and would appreciate any '
        'update on the hiring timeline.\n\n'
        'Thank you for your time.\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Responding to a recruiter outreach',
    category: 'Response',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you for reaching out — the [Job Title] role sounds like a '
        'great match for my skills in [area]. I would be glad to learn more.\n\n'
        'Could we set up a short call this week? I am generally available '
        '[days/times]. Looking forward to connecting.\n\n'
        'Best,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Requesting a referral',
    category: 'Networking',
    body:
        'Hi [Contact Name],\n\n'
        'I hope you are well. I am applying for the [Job Title] role at '
        '[Company] and saw that you work there. If you feel comfortable, I '
        'would be grateful for a referral or any insight into the team.\n\n'
        'Happy to share my resume and more about my background. Thank you so '
        'much for considering it.\n\n'
        'Best,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Confirming interview availability',
    category: 'Scheduling',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you for the invitation to interview for the [Job Title] role. '
        'I am available on [option 1] and [option 2]. Please let me know '
        'which works best, or feel free to suggest another time.\n\n'
        'I look forward to speaking with the team.\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Rescheduling an interview',
    category: 'Scheduling',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you again for scheduling our interview. Unfortunately, a '
        'conflict has come up and I need to request a new time. I sincerely '
        'apologize for any inconvenience.\n\n'
        'I am available on [alternative options] and remain very excited '
        'about the role. Thank you for your understanding.\n\n'
        'Best,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Asking about next steps',
    category: 'Follow-up',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you again for the interview on [date]. I wanted to check in '
        'on the next steps in the process and the expected timeline for a '
        'decision.\n\n'
        'I remain very interested in the [Job Title] role and am happy to '
        'provide any additional information. Thank you!\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Negotiating a salary offer',
    category: 'Offer',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you so much for the offer for the [Job Title] role — I am '
        'thrilled at the prospect of joining [Company]. Based on my '
        'experience and market research for this role, I was hoping we could '
        'discuss a base salary closer to [target figure].\n\n'
        'I am confident we can find a package that works for both of us and '
        'am excited to move forward.\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Accepting a job offer',
    category: 'Offer',
    body:
        'Hi [Recruiter Name],\n\n'
        'I am delighted to formally accept the offer for the [Job Title] '
        'role at [Company]. Thank you for your support throughout the '
        'process — I am excited to join the team.\n\n'
        'Please let me know the next steps regarding paperwork and start '
        'date. Looking forward to getting started.\n\n'
        'Warm regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Politely declining an offer',
    category: 'Offer',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you very much for offering me the [Job Title] role. After '
        'careful consideration, I have decided to pursue another opportunity '
        'that more closely aligns with my current goals.\n\n'
        'I truly appreciate the time the team invested in me and hope we can '
        'stay in touch for the future.\n\n'
        'Best regards,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Withdrawing an application',
    category: 'Response',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you for considering my application for the [Job Title] role. '
        'I am writing to respectfully withdraw from the process, as my '
        'circumstances have changed.\n\n'
        'I appreciate your time and would welcome the chance to connect on '
        'future opportunities.\n\n'
        'Best,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Requesting feedback after rejection',
    category: 'Follow-up',
    body:
        'Hi [Recruiter Name],\n\n'
        'Thank you for letting me know about your decision regarding the '
        '[Job Title] role. While I am disappointed, I appreciate the '
        'opportunity to interview.\n\n'
        'If possible, I would be grateful for any feedback that could help '
        'me grow. I would also love to be considered for future roles.\n\n'
        'Thank you,\n[Your Name]',
  ),
  RecruiterMessage(
    title: 'Cold outreach to a hiring manager',
    category: 'Networking',
    body:
        'Hi [Hiring Manager Name],\n\n'
        'I am a [Your Role] with [X years] of experience in [area], and I am '
        'genuinely impressed by [Company]\'s work on [project/product]. I '
        'would love the chance to contribute to your team.\n\n'
        'Would you be open to a brief conversation about how my background '
        'might fit current or upcoming needs? I have attached my resume.\n\n'
        'Thank you for your time,\n[Your Name]',
  ),
];

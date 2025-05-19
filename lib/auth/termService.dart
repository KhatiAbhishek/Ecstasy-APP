import 'package:flutter/material.dart';
import 'package:ecstasyapp/auth/login.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Introduction
                            Text(
                              'We require certain information to provide our services to you. For example, you must have an account in order to upload or share content on Ecstasy. When you choose to share the information below with us, we collect and use it to operate our services.',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),

                            // Basic Account Information
                            _SectionHeading('Basic Account Information'),
                            _SectionContent(
                              'If you choose to create an account, you must provide us with some personal data so that we can provide our services to you. On Ecstasy this includes a stage name, email address and phone number. Your stage name is always public, but you can use either your real name or a pseudonym.',
                            ),

                            // Contact Information
                            _SectionHeading('Contact Information'),
                            _SectionContent(
                              'Because our services are all about communicating with friends, we may — with your permission — collect information from your device’s phonebook and store it in our database (https://ecstasy*****.azurewebsites.net) for providing better user experience. We care about your privacy, so your data is encrypted and safely stored in high tech bunkers called server farms with no easy access to any human, AI or god inside or outside Ecstasy. We use your contact information, such as your email address or phone number, to authenticate your account and keep it - and our services - secure, and to help prevent spam, fraud, and abuse. Subject to your settings, we also use contact information to enable certain account features (for example, for login verification), to send you information about our services, and to personalise our services, including ads. If you provide us with your phone number, you agree to receive text messages from Ecstasy to that number as your country’s laws allow. Ecstasy also uses your contact information to market to you as your country’s laws allow, and to help others find your account if your settings permit, including through third-party services and client applications. You can use your settings for email and mobile notifications to control notifications you receive from Ecstasy. You can also unsubscribe from a notification by following the instructions contained within the notification. You can choose to upload and sync your address book on Ecstasy so that we can help you find and connect with people you know and help others find and connect with you. We also use this information to better recommend content to you and others. We use information like your email address, friends, or contacts list, to recommend other accounts or content to you or to recommend your account or content to others. If you email us, we will keep the content of your message, your email address, and your contact information to respond to your request.',
                            ),

                            // Storing Data
                            _SectionHeading('Storing Data'),
                            _SectionContent(
                              'We store your basic account information—like your name, phone number, contact list and email address—and list of friends until you ask us to delete them. If you wish to delete your personal data, you can write us to ecstasy@ecstasystage.com. We’re constantly collecting and updating information about the things you might like and dislike, so we can provide you with more relevant content and advertisements. We collect information from and about the devices you use. For example, we collect: information about your hardware and software, such as the hardware model, operating system version, device memory, advertising identifiers, unique application identifiers, unique device identifiers, browser type, language, and time zone; information about your wireless and mobile network connections, such as mobile phone number, service provider, IP address, and signal strength.',
                            ),

                            // Who May Use The Services
                            _SectionHeading('Who May Use The Services'),
                            _SectionContent(
                              'You may use the Services only if you agree to form a binding contract with Ecstasy and are not a person barred from receiving services under the laws of the applicable jurisdiction. In any case, you must be at least 13 years old to use the Services. If you are accepting these Terms and using the Services on behalf of a company, organisation, government, or other legal entity, you represent and warrant that you are authorised to do so and have the authority to bind such entity to these Terms, in which case the words “you” and “your” as used in these Terms shall refer to such entity.',
                            ),

                            // Using The Services
                            _SectionHeading('Using The Services'),
                            _SectionContent(
                              'In consideration for Ecstasy granting you access to and use of the services, you agree that Ecstasy and its third-party providers and partners may place advertising on the Services or in connection with the display of Content or information from the Services whether submitted by you or others. You also agree not to misuse our Services, for example, by interfering with them or accessing them using a method other than the interface and the instructions that we provide. You may not do any of the following while accessing or using the Services: (i) access, tamper with, or use non-public areas of the Services, Ecstasy’s computer systems, or the technical delivery systems of Ecstasy’s providers; (ii) probe, scan, or test the vulnerability of any system or network or breach or circumvent any security or authentication measures; (iii) access or search or attempt to access or search the Services by any means (automated or otherwise) other than through our currently available, published interfaces that are provided by Ecstasy (and only pursuant to the applicable terms and conditions), unless you have been specifically allowed to do so in a separate agreement with Ecstasy; (iv) forge any TCP/IP packet header or any part of the header information in any email or posting, or in any way use the Services to send altered, deceptive or false source-identifying information; or (v) interfere with, or disrupt, (or attempt to do so), the access of any user, host or network, including, without limitation, sending a virus, overloading, flooding, spamming, mail-bombing the Services, or by scripting the creation of Content in such a manner as to interfere with or create an undue burden on the Services. We also reserve the right to access, read, preserve, and disclose any information as we reasonably believe is necessary to (i) satisfy any applicable law, regulation, legal process or governmental request, (ii) enforce the Terms, including investigation of potential violations hereof, (iii) detect, prevent, or otherwise address fraud, security or technical issues, (iv) respond to user support requests, or (v) protect the rights, property or safety of Ecstasy, its users and the public. Ecstasy does not disclose personally-identifying information to third parties except in accordance with our Privacy Policy.',
                            ),

                            // Public Information
                            _SectionHeading('Public Information'),
                            _SectionContent(
                              'Most activity on Ecstasy is public, including your profile information, your display language, when you created your account, and your information like the name, type of account is publicly visible. When you share visual content on our service we may analyse that data to operate our services, for example by providing audio transcription or video subtitles. The lists you create, people you admire and who admires you. If you like, captions, reply, or otherwise publicly engage with an ad on our services, that advertiser might thereby learn information about you associated with the ad with which you engaged such as characteristics of the audience the ad was intended to reach. Broadcasts you create are public along with when you created them. Your engagement with broadcasts, including viewing, commenting, searching, reacting to, or otherwise participating in them, is public along with when you took those actions. Information posted about you by other people who use our services may also be public. For example, other people may tag you in a video. You are responsible for your engagement and other information you provide through our services, and you should think carefully about what you make public, especially if it is sensitive information. By publicly posting content, you are directing us to disclose that information as broadly as possible, including through our APIs, and directing those accessing the information through our APIs to do the same. To facilitate the fast global dissemination of videos to people around the world, we use technology like application programming interfaces (APIs) and embeds to make that information available to websites, apps, and others for their use - for example, displaying captions on a third party website or analysing what people say on platform. We generally make this content available in limited quantities for free. We have standard terms that govern how this data can be used, and a compliance program to enforce these terms. But these individuals and companies are not affiliated with Ecstasy, and their offerings may not reflect updates you make on Ecstasy.',
                            ),

                            // Cookies
                            _SectionHeading('Cookies'),
                            _SectionContent(
                              'A cookie is a small piece of data that is stored on your computer or mobile device. Like many websites, we use cookies and similar technologies to collect additional website usage data and to operate our services. Cookies are not required for many parts of our services such as searching and looking at public profiles. Although most web browsers automatically accept cookies, many browsers’ settings can be set to decline cookies or alert you when a website is attempting to place a cookie on your computer. However, some of our services may not function properly if you disable cookies. When your browser or device allows it, we use both session cookies and persistent cookies to better understand how you interact with our services, to monitor aggregate usage patterns, and to personalise and otherwise operate our services such as by providing account security, personalising the content we show you including ads, and remembering your language preferences. We do not support the Do Not Track browser option.',
                            ),

                            // Advertisers and Other Ad Partners
                            _SectionHeading('Advertisers and Other Ad Partners'),
                            _SectionContent(
                              'Advertising revenue allows us to support and improve our services. We use the information described in this terms of service to help make our advertising more relevant to you, to measure its effectiveness, and to help recognise your devices to serve you ads on Ecstasy. Our ad partners and affiliates share information with us such as browser cookie IDs, mobile device IDs, hashed email addresses, demographic or interest data, and content viewed or actions taken on a website or app. Some of our ad partners, particularly our advertisers, also enable us to collect similar information directly from their website or app by integrating our advertising technology. Information shared by ad partners and affiliates or collected by Ecstasy from the websites and apps of ad partners and affiliates may be combined with the other information you share with Ecstasy and that Ecstasy receives about you described elsewhere in our terms of service. Ecstasy adheres to the Digital Advertising Alliance Self-Regulatory Principles for Online Behavioural Advertising (also referred to as “interest-based advertising”) and respects the DAA’s consumer choice tool for you to opt-out of interest-based advertising based on categories that we consider sensitive or are prohibited by law, such as race, religion, politics, sex life, or health. If you are an advertiser or a prospective advertiser, we process your personal data to help offer and provide our advertising services.',
                            ),

                            // Other Third Parties and Affiliates
                            _SectionHeading('Other Third Parties and Affiliates'),
                            _SectionContent(
                              'We may receive information about you from third parties who are not our ad partners, such as others on Ecstasy, partners who help us evaluate the safety and quality of content on our platform, our corporate affiliates, and other services you link to your Ecstasy account. You may choose to connect your Ecstasy account to accounts on another service, and that other service may send us information about your account on that service. We use the information we receive to provide you features like cross-posting or cross-service authentication and to operate our services. For integrations that Ecstasy formally supports, you may revoke this permission at any time from your application settings; for other integrations, please visit the other service you have connected to Ecstasy.',
                            ),

                            // Your Content and Conduct
                            _MainHeading('Your Content and Conduct'),

                            // Uploading Content
                            _SectionHeading('Uploading Content'),
                            _SectionContent(
                              'If you have a Ecstasy Artist account, you may be able to upload Content to the Service. You may use your Content to promote your business or artistic enterprise. If you choose to upload Content, you must not submit to the Service any Content that does not comply with this Agreement. In particular, the Content must: respect the rights of others, including privacy; not include third-party intellectual property (such as copyrighted material) unless you have permission from that party or are otherwise legally entitled to do so; not abuse or harm others or yourself (or threaten or encourage such abuse or harm), including against children; not mislead, be patently false, or defrauding; not illegally impersonate, defame, bully, harass, be obscene or stalk others; not incite violation of applicable laws; not abuse, harm, interfere with, or disrupt the services — for example, by accessing or using them in fraudulent or deceptive ways, introducing malware, or spamming, hacking, or bypassing our systems or protective measures. You are legally responsible for the Content you submit to the Service. We may use automated systems that analyse your Content to help detect infringement and abuse, including spam and malware.',
                            ),

                            // Removing Your Content
                            _SectionHeading('Removing Your Content'),
                            _SectionContent(
                              'We can remove any content or information that you share on the Service if we believe that it violates these Terms of Use, our policies or we are permitted or required to do so by law. We can refuse to provide or stop providing all or part of the Service to you immediately to protect our community or services, or if you create risk or legal exposure for us, violate these Terms of Use or our policies, if you repeatedly infringe other people\'s intellectual property rights, or where we are permitted or required to do so by law. We can also terminate or change the Service, remove or block content or information shared on our Service, or stop providing all or part of the Service if we determine that doing so is reasonably necessary to avoid or mitigate adverse legal or regulatory impacts on us. If you believe that your account has been terminated in error, or you want to disable or permanently delete your account, you can delete your account and data from the app or email us at ecstasy@ecstasystage.com. When you request to delete content or your account, the deletion process will automatically begin no more than 24 hours after your request. It may take up to 30 days to delete content after the deletion process begins. While the deletion process for such content is being undertaken, the content is no longer visible to other users, but remains subject to these Terms of Use and our Data Policy. After the content is deleted, it may take us up to another 30 days to remove it from backups and disaster recovery systems. Content will not be deleted within 30 days of the account deletion or content deletion process beginning in the following situations: where your content has been used by others in accordance with this licence and they have not deleted it (in which case this licence will continue to apply until that content is deleted); or where deletion within 30 days is not possible due to technical limitations of our systems, in which case, we will complete the deletion as soon as technically feasible; or where deletion would restrict our ability to: investigate or identify illegal activity or violations of our terms and policies (for example, to identify or investigate misuse of our products or systems); protect the safety and security of our products, systems and users; comply with a legal obligation, such as the preservation of evidence; or comply with a request of a judicial or administrative authority, law enforcement or a government agency; in which case, the content will be retained for no longer than is necessary for the purposes for which it has been retained (the exact duration will vary on a case-by-case basis). If you delete or we disable your account, these Terms shall terminate as an agreement between you and us, but this section and the section below called "Our Agreement and What Happens if We Disagree" will still apply even after your account is terminated, disabled or deleted.',
                            ),

                            // Removal of Content By Ecstasy
                            _SectionHeading('Removal of Content By Ecstasy'),
                            _SectionContent(
                              'If we reasonably believe that any of your Content (1) is in breach of this Agreement or (2) may cause harm to Ecstasy, our users, or third parties, we reserve the right to remove or take down that Content in accordance with applicable law. We will notify you with the reason for our action unless we reasonably believe that to do so: (a) would breach the law or the direction of a legal enforcement authority or would otherwise risk legal liability for Ecstasy; (b) would compromise an investigation or the integrity or operation of the Service; or (c) would cause harm to any user, other third party.',
                            ),

                            // Rights you Grant
                            _MainHeading('Rights you Grant'),
                            _SectionContent(
                              'You retain ownership rights in your Content. However, we do require you to grant certain rights to Ecstasy and other users of the Service, as described below.',
                            ),

                            // License to Ecstasy
                            _SectionHeading('License to Ecstasy'),
                            _SectionContent(
                              'By providing Content to the Service, you grant to Ecstasy a worldwide, non-exclusive, royalty-free, transferable, sub-licensable license to use that Content (including to reproduce, distribute, prepare derivative works, display and perform it). Ecstasy may only use that Content in connection with the Service for the purpose of promoting and redistributing part or all of the Service.',
                            ),

                            // License to Other Users
                            _SectionHeading('License to Other Users'),
                            _SectionContent(
                              'You also grant each other user of the Service a worldwide, non-exclusive, royalty-free license to access your Content through the Service, and to use that Content, including to reproduce, distribute, prepare derivative works, display and perform it, only as enabled by a feature of the Service. For clarity, this license does not grant any rights or permissions for a user to make use of your Content independent of the Service.',
                            ),

                            // Duration of License
                            _SectionHeading('Duration of License'),
                            _SectionContent(
                              'The licenses granted by you continue for a commercially reasonable period of time after you remove or delete your Content from the Service. You understand and agree, however, that Ecstasy may retain, but not display, distribute, or perform, server copies of your videos that have been removed or deleted.',
                            ),

                            // Right to Monetize
                            _SectionHeading('Right to Monetize'),
                            _SectionContent(
                              'You grant to Ecstasy the right to monetize your Content on the Service (and such monetization may include displaying ads on or within Content or charging users a fee for access). This Agreement does not entitle you to any payments.',
                            ),

                            // Account Suspension & Termination
                            _MainHeading('Account Suspension & Termination'),

                            // Terminations by You
                            _SectionHeading('Terminations by You'),
                            _SectionContent(
                              'You may stop using the Service at any time.',
                            ),

                            // Terminations and Suspensions by Ecstasy
                            _SectionHeading('Terminations and Suspensions by Ecstasy'),
                            _SectionContent(
                              'Ecstasy reserves the right to suspend or terminate your account or your access to all or part of the Service if: (a) you materially or repeatedly breach this Agreement; (b) we are required to do so to comply with a legal requirement or a court order; or (c) we believe there has been conduct that creates (or could create) liability or harm to any user, other third party.',
                            ),

                            // Notice for Termination or Suspension
                            _SectionHeading('Notice for Termination or Suspension'),
                            _SectionContent(
                              'We will notify you with the reason for termination or suspension by Ecstasy unless we reasonably believe that to do so: (a) would violate the law or the direction of a legal enforcement authority; (b) would compromise an investigation; (c) would compromise the integrity, operation or security of the Service; or (d) would cause harm to any user, other third party. Where Ecstasy is terminating your use for Service changes, where reasonably possible, you will be provided with sufficient time to export your Content from the Service.',
                            ),

                            // Effect of Account Suspension or Termination
                            _SectionHeading('Effect of Account Suspension or Termination'),
                            _SectionContent(
                              'If your account is terminated or your access to the Service is restricted, you can’t continue using any aspects of the Service without an account, and this Agreement will continue to apply to such use.',
                            ),

                            // Community Guidelines
                            _MainHeading('Community Guidelines'),

                            // Manual Review System
                            _SectionHeading('Manual Review System'),
                            _SectionContent(
                              'Creating Art is a tiring avenue. You can now sit back and relax. Leave the rest to Ecstasy. Video will be live on platform after MRS approval. You’ll receive the notification for approval/disapproval. Ecstasy is a video platform specialised for entertainment purpose; Meanwhile there are number of content classifications in the video arena, we are not a stage for every sort of video content. We have specified ourself just for 5:15 minutes imaginative video content covering categories like art activities, cinematography, comedy, films, teasers, trailers, dance, music, theatre, acting, performing, satire and so on. We have designed a monitoring dashboard called MRS which permits us to approve or disprove the uploaded content by third party creators and artists. Once the video is uploaded, it doesn’t get air on the platform instantly, instead goes through MRS dashboard first, where we either manually or through machine learning AI audits it and approves/ disapproves it, then only gets publicly air to your admirers and other users on the app. If your content is disapproved, we’ll provide you concrete disapproval reason over your provided email address. Noone can envision how far your art content can rises above creative mind and amusement and transcends human imagination, however we understand what awful impact negative and bad content can affect our brains with. So we have made strict guidelines for the kind of content we don\'t acknowledge/approve.',
                            ),

                            // Nudity or Sexual Content
                            _SectionHeading('Nudity or Sexual Content'),
                            _SectionContent(
                              'Ecstasy isn\'t for erotic entertainment or explicitly express substance. If this portrays your video, regardless of whether it\'s a video of yourself, don\'t post it on Ecstasy. Likewise, be exhorted that we work intimately with law requirement and we report child exploitation.',
                            ),

                            // Harmful or Dangerous Content
                            _SectionHeading('Harmful or Dangerous Content'),
                            _SectionContent(
                              'Try not to post recordings that urge others to do things that may make them get hurt in any form, particularly kids. Recordings demonstrating such hurtful or perilous acts may get age-limited or evicted relying upon their seriousness.',
                            ),

                            // Hateful Content
                            _SectionHeading('Hateful Content'),
                            _SectionContent(
                              'Our items are stages with the expectation of complimentary expansion. Yet, we don\'t support content that advances or supports brutality against people or gatherings dependent on race or ethnic origin, religion, handicap, sex, age, nationality, veteran status, position, sexual direction, or sex personality, or substance that induces hatred based on these centre qualities. It\'s not all right to post a rough or violent substance that is essentially proposed to be shocking, exciting, or unwarranted. If posting such a substance, it would be ideal if you be careful to give enough information to help individuals comprehend what\'s happening in the video. Try not to urge others to submit explicit demonstrations of violence.',
                            ),

                            // Share only photos and videos that you’ve rendered or have the right to share
                            _SectionHeading('Share only photos and videos that you’ve rendered or have the right to share'),
                            _SectionContent(
                              'As always, you own the content you post on Ecstasy. Remember to post authentic content, and don’t post anything you’ve copied or collected from the Internet that you don’t have the right to post.',
                            ),

                            // Post photos and videos that are appropriate for a diverse audience
                            _SectionHeading('Post photos and videos that are appropriate for a diverse audience'),
                            _SectionContent(
                              'We know that there are times when people might want to share nude images or videos that are artistic or creative in nature, but for a variety of reasons, we don’t allow nudity on Ecstasy. This includes photos, videos, and some digitally-created content that show sexual intercourse, genitals, and close-ups of fully-nude buttocks. It also includes some photos of female nipples, but photos in the context of breastfeeding, birth giving and after-birth moments, health-related situations (for example, post-mastectomy, breast cancer awareness or gender confirmation surgery) or an act of protest are allowed. Nudity in photos of paintings and sculptures is OK, too.',
                            ),

                            // Foster meaningful and genuine interactions
                            _SectionHeading('Foster meaningful and genuine interactions'),
                            _SectionContent(
                              'Help us stay spam-free by not artificially collecting likes, admirers, or shares, posting repetitive comments or content, or repeatedly contacting people for commercial purposes without their consent. Don’t offer money or giveaways of money in exchange for likes, admirers, comments or other engagement. Don’t post content that engages in, promotes, encourages, facilitates, or admits to the offering, solicitation or trade of fake and misleading user reviews or ratings. You don’t have to use your real name on Ecstasy, but we do require Ecstasy users to provide us with accurate and up to date information. Don\'t impersonate others and don\'t create accounts for the purpose of violating our guidelines or misleading others.',
                            ),

                            // Follow the law
                            _SectionHeading('Follow the law'),
                            _SectionContent(
                              'Ecstasy is not a place to support or praise terrorism, organized crime, or hate groups. Offering sexual services, buying or selling firearms, alcohol, and tobacco products between private individuals, and buying or selling non-medical or pharmaceutical drugs are also not allowed. We also remove content that attempts to trade, co-ordinate the trade of, donate, gift, or ask for non-medical drugs, as well as content that either admits to personal use (unless in the recovery context) or coordinates or promotes the use of non-medical drugs. Accounts promoting online gambling, online real money games of skill or online lotteries must get our prior written permission before using any of our products. We have zero tolerance when it comes to sharing sexual content involving minors or threatening to post intimate images of others.',
                            ),

                            // Respect other members of the Ecstasy community
                            _SectionHeading('Respect other members of the Ecstasy community'),
                            _SectionContent(
                              'We want to foster a positive, diverse community. We remove content that contains credible threats or hate speech, content that targets private individuals to degrade or shame them, personal information meant to blackmail or harass someone, and repeated unwanted messages. We do generally allow stronger conversation around people who are featured in the news or have a large public audience due to their profession or chosen activities. It\'s never OK to encourage violence or attack anyone based on their race, ethnicity, national origin, sex, gender, gender identity, sexual orientation, religious affiliation, disabilities, or diseases. When hate speech is being shared to challenge it or to raise awareness, we may allow it. In those instances, we ask that you express your intent clearly. Serious threats of harm to public and personal safety aren\'t allowed. This includes specific threats of physical harm as well as threats of theft, vandalism, and other financial harm. We carefully review reports of threats and consider many things when determining whether a threat is credible.',
                            ),

                            // Maintain our supportive environment by not glorifying self-injury
                            _SectionHeading('Maintain our supportive environment by not glorifying self-injury'),
                            _SectionContent(
                              'The Ecstasy community cares for each other, and is often a place where people facing difficult issues such as eating disorders, cutting, or other kinds of self-injury come together to create awareness or find support. Encouraging or urging people to embrace self-injury is counter to this environment of support, and we’ll remove it or disable accounts if it’s reported to us. We may also remove content identifying victims or survivors of self-injury if the content targets them for attack or humour.',
                            ),

                            // Help us keep the community strong
                            _SectionHeading('Help us keep the community strong'),
                            _SectionContent(
                              'Each of us is an important part of the community. If you see something that you think may violate our guidelines, please help us by using our built-in reporting option. We have a team that reviews these reports and works as quickly as possible to remove content that doesn’t meet our guidelines. We may remove entire posts if either the imagery or associated captions violate our guidelines. You may find content you don’t like, but doesn’t violate the Community Guidelines. If that happens, you can unfollow or block the person who posted it. If there\'s something you don\'t like in a comment on one of your posts, you can delete that comment. Many disputes and misunderstandings can be resolved directly between members of the community. If one of your photos or videos was posted by someone else, you could try commenting on the post and asking the person to take it down. If that doesn’t work, you can file a copyright report. If you believe someone is violating your trademark, you can file a trademark report. Don\'t target the person who posted it by posting screenshots and drawing attention to the situation because that may be classified as harassment. We may work with law enforcement, including when we believe that there’s risk of physical harm or threat to public safety.',
                            ),

                            // Harassment or Cyber-bullying
                            _SectionHeading('Harassment or Cyber-bullying'),
                            _SectionContent(
                              'It\'s not all right to post damaging recordings and remarks. If provocation goes too far into a malevolent assault it very well may be accounted for and might be expelled. In different cases, clients might be somewhat irritating or unimportant and ought to be disregarded.',
                            ),

                            // Threats
                            _SectionHeading('Threats'),
                            _SectionContent(
                              'Things like savage conduct, stalking, dangers, badgering, terrorising, attacking protection, uncovering others\' personal information, and actuating others to submit rough acts or to damage the Terms of Use are taken very seriously. Anybody found doing these things might be forever restricted from Ecstasy.',
                            ),

                            // Copyright
                            _SectionHeading('Copyright'),
                            _SectionContent(
                              'Respect copyright. Only upload videos that you made or that you\'re authorised to use. These means don\'t upload videos you didn\'t make or use content in your videos that someone else owns the copyright to, such as music tracks, snippets of copyrighted programs, or videos made by other users, without necessary authorisations. Visit our Copyright Center for more information.',
                            ),

                            // Privacy
                            _SectionHeading('Privacy'),
                            _SectionContent(
                              'In the event that somebody has posted your own data or transferred a video of you without your assent, you can demand the expulsion of substance-dependent on our Privacy Guidelines.',
                            ),

                            // Impersonation
                            _SectionHeading('Impersonation'),
                            _SectionContent(
                              'Accounts that are established to impersonate another channel or individual may be removed under our impersonation policy.',
                            ),

                            // Children
                            _SectionHeading('Children'),
                            _SectionContent(
                              'Our services are not intended for — and we don’t direct them to — anyone under 13. And that’s why we do not knowingly collect personal information from anyone under 13. In addition, we may limit how we collect, use, and store some of the information of EEA and UK users between 13 and 16. In some cases, this means we will be unable to provide certain functionality to these users. If we need to rely on consent as a legal basis for processing your information and your country requires consent from a parent, we may require your parent’s consent before we collect and use that information.',
                            ),

                            // Additional Policies
                            _MainHeading('Additional Policies'),
                            _SectionContent(
                              'Additional policies on a range of subjects.',
                            ),

                            // Termination
                            _SectionHeading('Termination'),
                            _SectionContent(
                              'We may change, suspend, or end your entrance to or utilisation of our Services whenever under any circumstances, for example, if you abuse the letter or soul of our Terms or make damage, hazard, or conceivable lawful presentation for us, our clients, or others. The accompanying arrangements will endure any end of your relationship with Ecstasy: "Licenses," "Disclaimers," "Confinement of Liability," "Reimbursement," "Contest Resolution," "Accessibility and Termination of our Services," "Other," and "Uncommon Arbitration Provision for users."',
                            ),

                            // Content on the Services
                            _SectionHeading('Content on the Services'),
                            _SectionContent(
                              'You are responsible for your use of the Services and for any Content you provide, including compliance with applicable laws, rules, and regulations. You should only provide Content that you are comfortable sharing with others. Any use or reliance on any Content or materials posted via the Services or obtained by you through the Services is at your own risk. We do not endorse, support, represent or guarantee the completeness, truthfulness, accuracy, or reliability of any Content or communications posted via the Services or endorse any opinions expressed via the Services. You understand that by using the Services, you may be exposed to Content that might be offensive, harmful, inaccurate or otherwise inappropriate, or in some cases, postings that have been mislabeled or are otherwise deceptive. All Content is the sole responsibility of the person who originated such Content. We are monitoring or control the Content posted via the Services and, we have all the rights to take down any foul and inappropriate content without any warning or letter of consent. If you believe that your Content has been copied in a way that constitutes copyright infringement, please report this by visiting that specific profile or content to ecstasy@ecstasystage.com.',
                            ),

                            // Copyright
                            _SectionHeading('Copyright'),
                            _SectionContent(
                              'In many countries, when a person creates an original piece of work that is fixed in a physical medium, they automatically own the copyright to the work. As the copyright owner, they have the exclusive right to use the work. Most of the time, only the copyright owner can say whether someone else has permission to use the work. Work subjected to copyright are: Audiovisual works, such as TV shows, movies and online videos; Sound recordings and musical compositions; Written works, such as lectures, articles, books and musical compositions; Visual works, such as paintings, posters and advertisements; Video games and computer software; Dramatic works, such as plays and musicals. Ideas, facts and processes are not subject to copyright. According to copyright law, in order to be eligible for copyright protection, a work must be creative and it must be fixed in a tangible medium. Names and titles are not, by themselves, subject to copyright.',
                            ),

                            // Can Ecstasy determine Copyright Ownership?
                            _SectionHeading('Can Ecstasy determine Copyright Ownership?'),
                            _SectionContent(
                              'No. Ecstasy isn\'t able to mediate rights ownership disputes. When we receive a complete and valid takedown notice, we remove the content as the law requires. When we receive a valid counter-notification, we forward it to the person who requested the removal. After this, it\'s up to the parties involved to resolve the issue in court. Copyright is just one form of intellectual property. It\'s not the same as a trademark, which protects brand names, mottos, logos and other source identifiers from being used by others for certain purposes. It is also different from patent law, which protects inventions. Just because you appear in a video, image or audio recording does not mean that you own the copyright to it. For example, if your friend filmed a conversation between the two of you, she would own the copyright to that video recording. The words that the two of you are speaking are not subject to copyright separately from the video itself unless they were fixed in advance. If your friend, or someone else, has uploaded a video, image or recording of you without your permission and you feel that it violates your privacy or safety, you may wish to report to us.',
                            ),

                            // Revisions to the Terms of Service
                            _SectionHeading('Revisions to the Terms of Service'),
                            _SectionContent(
                              'We may change this Privacy Policy from time to time. But when we do, we’ll let you know one way or another. Sometimes, we’ll let you know by revising the date at the top of the Privacy Policy that’s available on our website and mobile application. Other times, we may provide you with additional notice (such as adding a statement to our websites’ homepages or providing you with an in-app notification).',
                            ),

                            // Footer
                            SizedBox(height: 30),
                            _FooterText('© Ecstasy Stage 2023'),
                            _FooterText('Rapturous Technologies Private Limited. U92419DL2019PTC355264'),
                            _FooterText('All rights reserved.'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1.5,
                      indent: 0,
                      endIndent: 0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Disagree',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                ' Agree',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for section headings
class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget for main headings
class _MainHeading extends StatelessWidget {
  final String title;

  const _MainHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget for section content
class _SectionContent extends StatelessWidget {
  final String content;

  const _SectionContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16),
    );
  }
}

// Widget for footer text
class _FooterText extends StatelessWidget {
  final String text;

  const _FooterText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
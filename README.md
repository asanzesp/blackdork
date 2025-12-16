# Blackdork

An automated reconnaissance and OSINT tool written in Bash. BlackDork performs advanced searches (Google Dorks) targeting domains, names, emails, and companies.

Unlike other scripts, BlackDork utilizes StartPage as an intermediary to execute its queries. This allows it to obtain the accuracy of Google results while leveraging StartPage's privacy features, avoiding direct tracking, and mitigating the CAPTCHAs commonly faced in mass dorking.

Key Features:

• 🔍 StartPage Engine: Performs anonymous dorking without directly accessing Google's servers.

• 🎯 Multi-Target: Supports domains, full names, companies, emails, and usernames.

• 📄 Reporting: Formatted output in XML and Text (Nmap-style) for easy integration.

• ⚙️ Customizable: Load your own lists of dorks or use the default ones.

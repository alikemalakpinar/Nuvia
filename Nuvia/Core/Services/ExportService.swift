import Foundation
import SwiftUI
import PDFKit

/// PDF, CSV, JSON dışa aktarma servisi
/// Bütçe raporları, davetli listeleri, oturma planı ve düğün kitabı oluşturma
class ExportService {

    // MARK: - PDF Export

    static func generateBudgetPDF(project: WeddingProject) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Nuvia",
            kCGPDFContextAuthor: "\(project.partnerName1) & \(project.partnerName2)",
            kCGPDFContextTitle: "Bütçe Raporu"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let symbol = Currency(rawValue: project.currency)?.symbol ?? "₺"

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.label]
            let title = "Bütçe Raporu"
            title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
            y += 40

            // Subtitle
            let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: UIColor.secondaryLabel]
            let subtitle = "\(project.partnerName1) & \(project.partnerName2) - \(project.weddingDate.formatted(date: .long, time: .omitted))"
            subtitle.draw(at: CGPoint(x: margin, y: y), withAttributes: subtitleAttributes)
            y += 30

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: y))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: y))
            UIColor.separator.setStroke()
            dividerPath.lineWidth = 1
            dividerPath.stroke()
            y += 20

            // Summary
            let summaryFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            let summaryAttributes: [NSAttributedString.Key: Any] = [.font: summaryFont, .foregroundColor: UIColor.label]

            "Toplam Bütçe: \(symbol)\(Int(project.totalBudget).formatted())".draw(at: CGPoint(x: margin, y: y), withAttributes: summaryAttributes)
            y += 25
            "Harcanan: \(symbol)\(Int(project.spentAmount).formatted())".draw(at: CGPoint(x: margin, y: y), withAttributes: summaryAttributes)
            y += 25
            "Kalan: \(symbol)\(Int(project.remainingBudget).formatted())".draw(at: CGPoint(x: margin, y: y), withAttributes: summaryAttributes)
            y += 40

            // Category breakdown
            let headerFont = UIFont.systemFont(ofSize: 18, weight: .bold)
            let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.label]
            "Kategori Dağılımı".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
            y += 30

            var categoryTotals: [ExpenseCategory: Double] = [:]
            for expense in project.expenses {
                categoryTotals[expense.expenseCategory, default: 0] += expense.amount
            }

            let rowFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.label]
            let amountAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.secondaryLabel]

            for (category, total) in categoryTotals.sorted(by: { $0.value > $1.value }) {
                if y > pageHeight - 100 {
                    context.beginPage()
                    y = margin
                }

                category.displayName.draw(at: CGPoint(x: margin, y: y), withAttributes: rowAttributes)
                let amountText = "\(symbol)\(Int(total).formatted())"
                let amountSize = amountText.size(withAttributes: amountAttributes)
                amountText.draw(at: CGPoint(x: pageWidth - margin - amountSize.width, y: y), withAttributes: amountAttributes)
                y += 20
            }

            y += 30

            // All expenses
            "Tüm Harcamalar".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
            y += 30

            // Table header
            let tableHeaderFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
            let tableHeaderAttributes: [NSAttributedString.Key: Any] = [.font: tableHeaderFont, .foregroundColor: UIColor.secondaryLabel]

            "Tarih".draw(at: CGPoint(x: margin, y: y), withAttributes: tableHeaderAttributes)
            "Açıklama".draw(at: CGPoint(x: margin + 80, y: y), withAttributes: tableHeaderAttributes)
            "Kategori".draw(at: CGPoint(x: margin + 280, y: y), withAttributes: tableHeaderAttributes)
            "Tutar".draw(at: CGPoint(x: margin + 400, y: y), withAttributes: tableHeaderAttributes)
            "Durum".draw(at: CGPoint(x: margin + 470, y: y), withAttributes: tableHeaderAttributes)
            y += 18

            let cellFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let cellAttributes: [NSAttributedString.Key: Any] = [.font: cellFont, .foregroundColor: UIColor.label]

            for expense in project.expenses.sorted(by: { $0.date < $1.date }) {
                if y > pageHeight - 60 {
                    context.beginPage()
                    y = margin
                }

                expense.date.formatted(date: .numeric, time: .omitted).draw(at: CGPoint(x: margin, y: y), withAttributes: cellAttributes)
                String(expense.title.prefix(30)).draw(at: CGPoint(x: margin + 80, y: y), withAttributes: cellAttributes)
                expense.expenseCategory.displayName.draw(at: CGPoint(x: margin + 280, y: y), withAttributes: cellAttributes)
                "\(symbol)\(Int(expense.amount).formatted())".draw(at: CGPoint(x: margin + 400, y: y), withAttributes: cellAttributes)
                (expense.isPaid ? "Ödendi" : "Bekliyor").draw(at: CGPoint(x: margin + 470, y: y), withAttributes: cellAttributes)
                y += 16
            }

            // Footer
            y = pageHeight - 40
            let footerFont = UIFont.systemFont(ofSize: 8, weight: .regular)
            let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.tertiaryLabel]
            "Nuvia - \(Date().formatted(date: .long, time: .shortened)) tarihinde oluşturuldu".draw(at: CGPoint(x: margin, y: y), withAttributes: footerAttributes)
        }

        return data
    }

    static func generateGuestListPDF(project: WeddingProject) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.label]
            "Davetli Listesi".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
            y += 40

            let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: UIColor.secondaryLabel]
            "Toplam: \(project.guests.count) davetli, \(project.totalGuests) kişi".draw(at: CGPoint(x: margin, y: y), withAttributes: subtitleAttributes)
            y += 30

            // Table header
            let headerFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
            let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.secondaryLabel]
            "Ad Soyad".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
            "Grup".draw(at: CGPoint(x: margin + 180, y: y), withAttributes: headerAttributes)
            "RSVP".draw(at: CGPoint(x: margin + 300, y: y), withAttributes: headerAttributes)
            "+1".draw(at: CGPoint(x: margin + 380, y: y), withAttributes: headerAttributes)
            "Masa".draw(at: CGPoint(x: margin + 420, y: y), withAttributes: headerAttributes)
            y += 18

            let cellFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let cellAttributes: [NSAttributedString.Key: Any] = [.font: cellFont, .foregroundColor: UIColor.label]

            for guest in project.guests.sorted(by: { $0.lastName < $1.lastName }) {
                if y > pageHeight - 60 {
                    context.beginPage()
                    y = margin
                }

                guest.fullName.draw(at: CGPoint(x: margin, y: y), withAttributes: cellAttributes)
                guest.guestGroup.displayName.draw(at: CGPoint(x: margin + 180, y: y), withAttributes: cellAttributes)
                guest.rsvp.displayName.draw(at: CGPoint(x: margin + 300, y: y), withAttributes: cellAttributes)
                "\(guest.plusOneCount)".draw(at: CGPoint(x: margin + 380, y: y), withAttributes: cellAttributes)

                let tableName = guest.seatAssignment?.table?.name ?? "-"
                tableName.draw(at: CGPoint(x: margin + 420, y: y), withAttributes: cellAttributes)
                y += 16
            }
        }

        return data
    }

    static func generateSeatingPlanPDF(project: WeddingProject) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 792 // Landscape
        let pageHeight: CGFloat = 612
        let margin: CGFloat = 40
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.label]
            "Oturma Planı".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
            y += 40

            let tableHeaderFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            let tableHeaderAttributes: [NSAttributedString.Key: Any] = [.font: tableHeaderFont, .foregroundColor: UIColor.label]

            let guestFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let guestAttributes: [NSAttributedString.Key: Any] = [.font: guestFont, .foregroundColor: UIColor.label]

            for table in project.tables.sorted(by: { $0.tableNumber < $1.tableNumber }) {
                if y > pageHeight - 100 {
                    context.beginPage()
                    y = margin
                }

                // Table header
                "\(table.name) (\(table.occupiedSeats)/\(table.capacity))".draw(at: CGPoint(x: margin, y: y), withAttributes: tableHeaderAttributes)
                y += 22

                // Guests
                for guest in table.seatedGuests {
                    "  • \(guest.fullName)\(guest.plusOneCount > 0 ? " +\(guest.plusOneCount)" : "")".draw(at: CGPoint(x: margin + 20, y: y), withAttributes: guestAttributes)
                    y += 16
                }

                if table.availableSeats > 0 {
                    "  (\(table.availableSeats) boş koltuk)".draw(at: CGPoint(x: margin + 20, y: y), withAttributes: [.font: guestFont, .foregroundColor: UIColor.tertiaryLabel])
                    y += 16
                }

                y += 10
            }
        }

        return data
    }

    // MARK: - CSV Export

    static func generateBudgetCSV(project: WeddingProject) -> String {
        let symbol = Currency(rawValue: project.currency)?.symbol ?? "₺"
        var csv = "Tarih,Açıklama,Kategori,Tutar (\(symbol)),Ödeme Tipi,Durum,Tedarikçi\n"

        for expense in project.expenses.sorted(by: { $0.date < $1.date }) {
            let date = expense.date.formatted(date: .numeric, time: .omitted)
            let title = expense.title.replacingOccurrences(of: ",", with: ";")
            let category = expense.expenseCategory.displayName
            let amount = String(format: "%.2f", expense.amount)
            let paymentType = expense.expensePaymentType.displayName
            let status = expense.isPaid ? "Ödendi" : "Bekliyor"
            let vendor = expense.vendor?.name ?? ""

            csv += "\(date),\(title),\(category),\(amount),\(paymentType),\(status),\(vendor)\n"
        }

        csv += "\n\nToplam Bütçe,\(String(format: "%.2f", project.totalBudget))\n"
        csv += "Harcanan,\(String(format: "%.2f", project.spentAmount))\n"
        csv += "Kalan,\(String(format: "%.2f", project.remainingBudget))\n"

        return csv
    }

    static func generateGuestListCSV(project: WeddingProject) -> String {
        var csv = "Ad,Soyad,Grup,RSVP,+1 Sayısı,Telefon,E-posta,Masa,Notlar,Etiketler\n"

        for guest in project.guests.sorted(by: { $0.lastName < $1.lastName }) {
            let table = guest.seatAssignment?.table?.name ?? ""
            let tags = guest.tags.joined(separator: "; ")
            let notes = (guest.notes ?? "").replacingOccurrences(of: ",", with: ";")

            csv += "\(guest.firstName),\(guest.lastName),\(guest.guestGroup.displayName),\(guest.rsvp.displayName),\(guest.plusOneCount),\(guest.phone ?? ""),\(guest.email ?? ""),\(table),\(notes),\(tags)\n"
        }

        return csv
    }

    // MARK: - JSON Export

    static func generateProjectJSON(project: WeddingProject) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let exportData = ProjectExportData(project: project)

        guard let data = try? encoder.encode(exportData) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Wedding Book PDF

    static func generateWeddingBookPDF(project: WeddingProject) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 60
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            // Cover page
            context.beginPage()
            let coverFont = UIFont.systemFont(ofSize: 36, weight: .bold)
            let coverAttributes: [NSAttributedString.Key: Any] = [.font: coverFont, .foregroundColor: UIColor.label]

            let title = "\(project.partnerName1) & \(project.partnerName2)"
            let titleSize = title.size(withAttributes: coverAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: pageHeight / 3), withAttributes: coverAttributes)

            let dateFont = UIFont.systemFont(ofSize: 18, weight: .regular)
            let dateAttributes: [NSAttributedString.Key: Any] = [.font: dateFont, .foregroundColor: UIColor.secondaryLabel]
            let dateText = project.weddingDate.formatted(date: .long, time: .omitted)
            let dateSize = dateText.size(withAttributes: dateAttributes)
            dateText.draw(at: CGPoint(x: (pageWidth - dateSize.width) / 2, y: pageHeight / 3 + 50), withAttributes: dateAttributes)

            let subtitleText = "Düğün Anı Defteri"
            let subtitleSize = subtitleText.size(withAttributes: dateAttributes)
            subtitleText.draw(at: CGPoint(x: (pageWidth - subtitleSize.width) / 2, y: pageHeight / 3 + 80), withAttributes: dateAttributes)

            // Journal entries
            let sortedEntries = project.journalEntries.sorted { $0.date < $1.date }

            let entryHeaderFont = UIFont.systemFont(ofSize: 16, weight: .bold)
            let entryHeaderAttributes: [NSAttributedString.Key: Any] = [.font: entryHeaderFont, .foregroundColor: UIColor.label]

            let entryBodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let entryBodyAttributes: [NSAttributedString.Key: Any] = [.font: entryBodyFont, .foregroundColor: UIColor.label]

            let entryDateFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let entryDateAttributes: [NSAttributedString.Key: Any] = [.font: entryDateFont, .foregroundColor: UIColor.tertiaryLabel]

            for entry in sortedEntries {
                context.beginPage()
                var y: CGFloat = margin

                // Date
                entry.formattedDate.draw(at: CGPoint(x: margin, y: y), withAttributes: entryDateAttributes)
                y += 20

                // Mood
                if let mood = entry.entryMood {
                    "\(mood.emoji) \(mood.displayName)".draw(at: CGPoint(x: margin, y: y), withAttributes: entryDateAttributes)
                    y += 20
                }

                // Title
                if let title = entry.title {
                    title.draw(at: CGPoint(x: margin, y: y), withAttributes: entryHeaderAttributes)
                    y += 30
                }

                // Content
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6
                let contentAttributes: [NSAttributedString.Key: Any] = [
                    .font: entryBodyFont,
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: paragraphStyle
                ]
                let contentRect = CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: pageHeight - y - margin)
                entry.content.draw(in: contentRect, withAttributes: contentAttributes)
            }

            // Stats page
            context.beginPage()
            var y: CGFloat = margin

            let statsHeaderFont = UIFont.systemFont(ofSize: 20, weight: .bold)
            let statsAttributes: [NSAttributedString.Key: Any] = [.font: statsHeaderFont, .foregroundColor: UIColor.label]
            "Düğün İstatistikleri".draw(at: CGPoint(x: margin, y: y), withAttributes: statsAttributes)
            y += 40

            let statsFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let statsBodyAttributes: [NSAttributedString.Key: Any] = [.font: statsFont, .foregroundColor: UIColor.label]

            let stats = [
                "Toplam Görev: \(project.tasks.count)",
                "Tamamlanan Görev: \(project.completedTasksCount)",
                "Toplam Davetli: \(project.guests.count) (\(project.totalGuests) kişi)",
                "Onaylanan: \(project.confirmedGuests) kişi",
                "Toplam Masa: \(project.tables.count)",
                "Tedarikçi Sayısı: \(project.vendors.count)",
                "Günlük Giriş Sayısı: \(project.journalEntries.count)",
                "Toplam Harcama: \(Currency(rawValue: project.currency)?.symbol ?? "₺")\(Int(project.spentAmount).formatted())"
            ]

            for stat in stats {
                stat.draw(at: CGPoint(x: margin, y: y), withAttributes: statsBodyAttributes)
                y += 25
            }

            // Footer
            let footerFont = UIFont.systemFont(ofSize: 8, weight: .regular)
            let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.tertiaryLabel]
            let footer = "Nuvia ile oluşturuldu - \(Date().formatted(date: .long, time: .omitted))"
            let footerSize = footer.size(withAttributes: footerAttributes)
            footer.draw(at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - 40), withAttributes: footerAttributes)
        }

        return data
    }

    // MARK: - File Sharing

    static func shareFile(data: Data, fileName: String, from viewController: UIViewController? = nil) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

        if let vc = viewController ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            vc.present(activityVC, animated: true)
        }
    }

    static func shareText(text: String, fileName: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? text.write(to: tempURL, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

        if let vc = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            vc.present(activityVC, animated: true)
        }
    }
}

// MARK: - Export Data Model

struct ProjectExportData: Codable {
    let exportDate: Date
    let appVersion: String
    let projectName: String
    let weddingDate: Date
    let partners: [String]
    let currency: String
    let totalBudget: Double
    let spentAmount: Double
    let guestCount: Int
    let taskCount: Int
    let completedTasks: Int

    init(project: WeddingProject) {
        self.exportDate = Date()
        self.appVersion = "1.0.0"
        self.projectName = "\(project.partnerName1) & \(project.partnerName2)"
        self.weddingDate = project.weddingDate
        self.partners = [project.partnerName1, project.partnerName2]
        self.currency = project.currency
        self.totalBudget = project.totalBudget
        self.spentAmount = project.spentAmount
        self.guestCount = project.guests.count
        self.taskCount = project.tasks.count
        self.completedTasks = project.completedTasksCount
    }
}

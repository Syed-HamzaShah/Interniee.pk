import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/resume_model.dart';
import 'package:intl/intl.dart';

class PDFService {
  Future<File> generateResumePDF(ResumeModel resume) async {
    final pdf = pw.Document();

    final primaryColor = _getColorFromScheme(resume.settings.colorScheme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(resume.personalInfo, primaryColor),
          pw.SizedBox(height: 20),
          if (resume.professionalSummary.isNotEmpty) ...[
            _buildSection('Professional Summary', [
              pw.Text(
                resume.professionalSummary,
                style: const pw.TextStyle(fontSize: 11),
                textAlign: pw.TextAlign.justify,
              ),
            ], primaryColor),
            pw.SizedBox(height: 15),
          ],
          if (resume.experience.isNotEmpty) ...[
            _buildSection(
              'Experience',
              resume.experience.map((exp) => _buildExperience(exp)).toList(),
              primaryColor,
            ),
            pw.SizedBox(height: 15),
          ],
          if (resume.education.isNotEmpty) ...[
            _buildSection(
              'Education',
              resume.education.map((edu) => _buildEducation(edu)).toList(),
              primaryColor,
            ),
            pw.SizedBox(height: 15),
          ],
          if (resume.skills.isNotEmpty) ...[
            _buildSection('Skills', [
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: resume.skills
                    .map(
                      (skill) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F1F5F9'),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                        ),
                        child: pw.Text(
                          skill,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ], primaryColor),
            pw.SizedBox(height: 15),
          ],
          if (resume.projects.isNotEmpty) ...[
            _buildSection(
              'Projects',
              resume.projects.map((proj) => _buildProject(proj)).toList(),
              primaryColor,
            ),
            pw.SizedBox(height: 15),
          ],
          if (resume.certifications.isNotEmpty) ...[
            _buildSection(
              'Certifications',
              resume.certifications
                  .map((cert) => _buildCertification(cert))
                  .toList(),
              primaryColor,
            ),
          ],
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${resume.title}_resume.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildHeader(PersonalInfo info, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          info.fullName,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        if (info.headline.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            info.headline,
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            if (info.email.isNotEmpty) _buildContactItem(info.email, color),
            if (info.phone.isNotEmpty) ...[
              pw.SizedBox(width: 20),
              _buildContactItem(info.phone, color),
            ],
            if (info.location.isNotEmpty) ...[
              pw.SizedBox(width: 20),
              _buildContactItem(info.location, color),
            ],
          ],
        ),
        if (info.linkedIn != null ||
            info.github != null ||
            info.portfolio != null) ...[
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              if (info.linkedIn != null)
                _buildContactItem(info.linkedIn!, color),
              if (info.github != null) ...[
                pw.SizedBox(width: 20),
                _buildContactItem(info.github!, color),
              ],
              if (info.portfolio != null) ...[
                pw.SizedBox(width: 20),
                _buildContactItem(info.portfolio!, color),
              ],
            ],
          ),
        ],
        pw.SizedBox(height: 10),
        pw.Divider(color: color, thickness: 2),
      ],
    );
  }

  pw.Widget _buildContactItem(String text, PdfColor color) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#475569')),
    );
  }

  pw.Widget _buildSection(
    String title,
    List<pw.Widget> content,
    PdfColor color,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 8),
        ...content,
      ],
    );
  }

  pw.Widget _buildExperience(WorkExperience exp) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDate = exp.startDate != null
        ? dateFormat.format(exp.startDate!)
        : '';
    final endDate = exp.isCurrentJob
        ? 'Present'
        : (exp.endDate != null ? dateFormat.format(exp.endDate!) : '');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    exp.jobTitle,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${exp.company}${exp.location.isNotEmpty ? " • ${exp.location}" : ""}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('#64748B'),
                    ),
                  ),
                ],
              ),
            ),
            if (startDate.isNotEmpty || endDate.isNotEmpty)
              pw.Text(
                '$startDate - $endDate',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#94A3B8'),
                ),
              ),
          ],
        ),
        if (exp.responsibilities.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          ...exp.responsibilities.map(
            (resp) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 15, bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child: pw.Text(
                      resp,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildEducation(Education edu) {
    final dateFormat = DateFormat('MMM yyyy');
    final gradDate = edu.graduationDate != null
        ? dateFormat.format(edu.graduationDate!)
        : '';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    edu.degree,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${edu.institution}${edu.location.isNotEmpty ? " • ${edu.location}" : ""}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('#64748B'),
                    ),
                  ),
                  if (edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty)
                    pw.Text(
                      edu.fieldOfStudy!,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromHex('#94A3B8'),
                      ),
                    ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (gradDate.isNotEmpty)
                  pw.Text(
                    gradDate,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#94A3B8'),
                    ),
                  ),
                if (edu.gpa != null && edu.gpa!.isNotEmpty)
                  pw.Text(
                    'GPA: ${edu.gpa}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#94A3B8'),
                    ),
                  ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildProject(Project proj) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          proj.title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(proj.description, style: const pw.TextStyle(fontSize: 10)),
        if (proj.technologies.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Technologies: ${proj.technologies.join(", ")}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#64748B'),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildCertification(Certification cert) {
    final dateFormat = DateFormat('MMM yyyy');
    final date = cert.dateObtained != null
        ? dateFormat.format(cert.dateObtained!)
        : '';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    cert.name,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    cert.issuer,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#64748B'),
                    ),
                  ),
                ],
              ),
            ),
            if (date.isNotEmpty)
              pw.Text(
                date,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#94A3B8'),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  PdfColor _getColorFromScheme(String scheme) {
    switch (scheme) {
      case 'blue':
        return PdfColor.fromHex('#3B82F6');
      case 'green':
        return PdfColor.fromHex('#10B981');
      case 'purple':
        return PdfColor.fromHex('#8B5CF6');
      case 'red':
        return PdfColor.fromHex('#EF4444');
      case 'orange':
        return PdfColor.fromHex('#F59E0B');
      default:
        return PdfColor.fromHex('#3B82F6');
    }
  }

  Future<void> previewPDF(File pdfFile) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfFile.readAsBytes());
  }

  Future<void> sharePDF(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}

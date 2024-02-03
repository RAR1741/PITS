package org.redalert.pits;

import javax.swing.JOptionPane;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class PITSUtility extends Frame implements ActionListener {
    private final TextField ipTextField;
    private final TextField directoryTextField;
    private final Button downloadButton;
    private final Button commitButton;
    public PITSUtility() {
        // Set layout
        setLayout(new FlowLayout(FlowLayout.LEADING, 10, 10));

        // IP Address Label and TextField
        add(new Label("IP Address:"));
        ipTextField = new TextField("10.17.41.2",25);
        add(ipTextField);

        // Directory Label and TextField
        add(new Label("Directory:"));
        directoryTextField = new TextField("/home/lvuser/logs",25);
        add(directoryTextField);

        // Download Button
        downloadButton = new Button("Download");
        add(downloadButton);
        downloadButton.addActionListener(this);

        // Commit Button
        commitButton = new Button("Commit");
        add(commitButton);
        commitButton.addActionListener(this);

        // Set frame properties
        setTitle("PITS Utility");
        setSize(235, 235);
        setVisible(true);

        // Handle window close event
        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent windowEvent) {
                System.exit(0);
            }
        });
    }

    // Action listener for buttons
    public void actionPerformed(ActionEvent e) {
        LogDownload downloader = new LogDownload();
        if (e.getSource() == downloadButton) {
            // Implement download functionality
            String ipAddress = ipTextField.getText();
            String directory = directoryTextField.getText();
            switch (downloader.download(ipAddress, directory)) {
                case 1:
                    JOptionPane.showMessageDialog(null, "Could not connect to robot", "Download error", JOptionPane.WARNING_MESSAGE);
                    break;
                case 2:
                    JOptionPane.showMessageDialog(null, "Robot refused connection", "Download error", JOptionPane.WARNING_MESSAGE);
                    break;
                default:
                    JOptionPane.showMessageDialog(null, "Download complete", "Success", JOptionPane.PLAIN_MESSAGE);
                    break;

            }
        } else if (e.getSource() == commitButton) {
            // Implement commit functionality
            String ipAddress = ipTextField.getText();
            String directory = directoryTextField.getText();
            System.out.println("Commit button clicked");
            System.out.println("IP Address: " + ipAddress);
            System.out.println("Directory: " + directory);
        }
    }
}

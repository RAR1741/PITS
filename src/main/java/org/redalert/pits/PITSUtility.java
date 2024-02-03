package org.redalert.pits;

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
        ipTextField = new TextField(25);
        add(ipTextField);

        // Directory Label and TextField
        add(new Label("Directory:"));
        directoryTextField = new TextField(25);
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
            downloader.download(ipAddress, directory);
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

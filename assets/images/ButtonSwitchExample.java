import javax.swing.*;
import java.awt.event.*; 

public class ButtonSwitchExample {
    private JButton button1;
    private JButton button2;
    // ... add more buttons if needed

    public ButtonSwitchExample() {
        JFrame frame = new JFrame("Switch Case with Buttons");
        JPanel panel = new JPanel();

        button1 = new JButton("Button 1");
        button2 = new JButton("Button 2");
        // ... create more buttons

        // Add ActionListeners (using a common handler)
        button1.addActionListener(new ButtonHandler());
        button2.addActionListener(new ButtonHandler());
        // ... add listeners to other buttons

        panel.add(button1);
        panel.add(button2);
        // ... add more buttons to the panel

        frame.add(panel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
    }

    // ActionListener for the buttons
    class ButtonHandler implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            JButton clickedButton = (JButton) e.getSource(); // Get the button that was clicked

            switch (clickedButton.getText()) {
                case "Button 1":
                    // Code for Button 1 action
                    System.out.println("Button 1 was clicked!");
                    break;
                case "Button 2":
                    // Code for Button 2 action
                    System.out.println("Button 2 was clicked!");
                    break;
                // Add more cases for other buttons
                default:
                    System.out.println("Unknown button clicked.");
            }
        }
    }

    public static void main(String[] args) {
        new ButtonSwitchExample();
    }
}
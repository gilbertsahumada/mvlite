mod server;
mod session_wrapper;

use anyhow::Result;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "mvlite", about = "Lightweight Move VM for local development")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Start the mvlite server
    Start {
        /// Port to listen on
        #[arg(short, long, default_value = "8090")]
        port: u16,

        /// Fork from a remote network URL
        #[arg(long)]
        fork_url: Option<String>,
    },
    /// Show version
    Version,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Start { port, fork_url } => {
            println!("mvlite v{}", env!("CARGO_PKG_VERSION"));
            println!();

            let session = session_wrapper::create_session(fork_url)?;

            println!("Listening on http://127.0.0.1:{}", port);
            println!("Press Ctrl+C to stop.");
            println!();

            server::run(session, port).await
        }
        Commands::Version => {
            println!("mvlite v{}", env!("CARGO_PKG_VERSION"));
            Ok(())
        }
    }
}

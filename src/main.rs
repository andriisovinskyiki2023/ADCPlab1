#[allow(dead_code)]
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    #[allow(non_snake_case)]
    fn BasicAddition() {
        assert_eq!(add(2, 3), 5);
    }
}
